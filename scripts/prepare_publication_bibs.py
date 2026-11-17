from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "generated"
OUT_DIR.mkdir(exist_ok=True)

MONTH_MAP = {
    "jan": "01",
    "january": "01",
    "feb": "02",
    "february": "02",
    "mar": "03",
    "march": "03",
    "apr": "04",
    "april": "04",
    "may": "05",
    "jun": "06",
    "june": "06",
    "jul": "07",
    "july": "07",
    "aug": "08",
    "august": "08",
    "sep": "09",
    "sept": "09",
    "september": "09",
    "oct": "10",
    "october": "10",
    "nov": "11",
    "november": "11",
    "dec": "12",
    "december": "12",
    "1": "01",
    "01": "01",
    "2": "02",
    "02": "02",
    "3": "03",
    "03": "03",
    "4": "04",
    "04": "04",
    "5": "05",
    "05": "05",
    "6": "06",
    "06": "06",
    "7": "07",
    "07": "07",
    "8": "08",
    "08": "08",
    "9": "09",
    "09": "09",
    "10": "10",
    "11": "11",
    "12": "12",
}

FIELD_RE = re.compile(r"(?im)^\s*(sortmonth|sortyear|sortkey)\s*=\s*\{[^}]*\},?\s*$")


def split_entries(text: str):
    parts = []
    cursor = 0
    while True:
        start = text.find("@", cursor)
        if start == -1:
            parts.append((False, text[cursor:]))
            break
        if start > cursor:
            parts.append((False, text[cursor:start]))
        depth = 0
        i = start
        seen_open = False
        while i < len(text):
            char = text[i]
            if char == "{" and not seen_open:
                seen_open = True
                depth = 1
            elif char == "{" and seen_open:
                depth += 1
            elif char == "}" and seen_open:
                depth -= 1
                if depth == 0:
                    i += 1
                    break
            i += 1
        parts.append((True, text[start:i]))
        cursor = i
    return parts


def normalize_entry(entry: str) -> str:
    cleaned = FIELD_RE.sub("", entry)
    year = None
    month = "99"
    for line in cleaned.splitlines():
        stripped = line.strip()
        if stripped.lower().startswith("year") and "=" in stripped:
            value = stripped.split("=", 1)[1].strip().rstrip(",")
            year = value.strip("{} ")
        elif stripped.lower().startswith("month") and "=" in stripped:
            value = stripped.split("=", 1)[1].strip().rstrip(",")
            token = value.strip("{} ").lower()
            month = MONTH_MAP.get(token, MONTH_MAP.get(token[:3], "99"))

    if not year:
        return cleaned

    lines = cleaned.rstrip().splitlines()
    if not lines:
        return cleaned

    closing_index = len(lines) - 1
    while closing_index >= 0 and lines[closing_index].strip() != "}":
        closing_index -= 1

    if closing_index < 0:
        return cleaned

    if closing_index > 0 and not lines[closing_index - 1].rstrip().endswith(","):
        lines[closing_index - 1] = lines[closing_index - 1].rstrip() + ","

    sortkey = f"{year}-{month}"
    lines.insert(closing_index, f"  sortyear = {{{year}}},")
    lines.insert(closing_index + 1, f"  sortmonth = {{{month}}},")
    lines.insert(closing_index + 2, f"  sortkey = {{{sortkey}}},")
    return "\n".join(lines) + "\n"


def transform(src_name: str, dst_name: str):
    src = ROOT / src_name
    dst = OUT_DIR / dst_name
    text = src.read_text(encoding="utf-8")
    out = []
    for is_entry, chunk in split_entries(text):
        out.append(normalize_entry(chunk) if is_entry else chunk)
    dst.write_text("".join(out), encoding="utf-8")


if __name__ == "__main__":
    transform("publications.bib", "publications_sorted.bib")
    transform("publications_not.bib", "publications_not_sorted.bib")
