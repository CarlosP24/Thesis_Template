$pdf_mode = 4;           # Use lualatex (required by fourier-otf)
$bibtex_use = 2;         # Run biber when needed
$do_cd = 1;              # Build from the source file directory (subfiles-friendly)

use Cwd qw(abs_path getcwd);
use File::Basename qw(dirname basename);
use File::Path qw(make_path);

# Locate the project root by walking up from the current directory until we
# find a known marker. Do NOT use __FILE__ here: latexmk evaluates rc-file
# *contents*, so __FILE__ is an eval context rather than this file's path,
# and abs_path() would silently resolve it against the current directory
# (giving e.g. ch1/ when building a chapter from its own directory).
my $project_root;
{
	my $dir = getcwd();
	for (1 .. 10) {
		if (-e "$dir/scripts/prepare_publication_bibs.py") { $project_root = $dir; last; }
		my $parent = dirname($dir);
		last if $parent eq $dir;
		$dir = $parent;
	}
	die "Could not locate thesis project root from " . getcwd() . "\n"
		unless $project_root;
}

# Keep bib file discovery working when latexmk changes into subdirectories.
$ENV{BIBINPUTS} = "$project_root:" . ($ENV{BIBINPUTS} // '');

# Write volatile build files (.aux/.bcf/.bbl/.fls/.fdb_latexmk/...) to a
# local cache dir OUTSIDE this Nextcloud-synced folder. Nextcloud's macOS
# File Provider intercepts renames on files inside the synced tree, which
# occasionally makes biber's atomic .bbl/.bcf write fail (it then silently
# keeps the stale bibliography and dumps the new one as "*-SAVE-ERROR").
# Only the finished PDF is copied back into the source directory, which
# isn't subject to that failure mode. Shared across all chapters/main since
# jobnames (ch1, ch2, main, ...) are unique.
my $aux_root = "$ENV{HOME}/.cache/thesis-template-latex-aux";
make_path($aux_root) unless -d $aux_root;
$aux_dir = $aux_root;
$out_dir = '.';

# Build glossaries and acronyms during the normal latexmk cycle.
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
	# latexmk sometimes passes a bare jobname, sometimes an aux_dir-qualified
	# path; normalize to the bare name so it doesn't collide with -d.
	my ($base_name) = @_;
	my $name = basename($base_name);
	return system("makeglossaries -d \"$aux_dir\" \"$name\"");
}

system("python3 \"$project_root/scripts/prepare_publication_bibs.py\"") == 0
	or die "Failed to generate normalized publication bib files\n";

# Clean up extra extensions
$clean_ext = 'run.xml bbl bcf fdb_latexmk fls synctex.gz';
