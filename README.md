# Supplementary code and data

**Sensitivity and biological discovery potential of two methods for whole genome
sequencing of *Leishmania braziliensis* amastigotes, directly in human tissues**

Pieter Monsieurs, Maria Edelmira Cruz Saldarriaga, Allison Aroni-Soto, Maria de
los Angeles Sernaque Palomino, Maria Pinedo Bardales, Jorge Arevalo, Frederik
Van den Broeck, Senne Heeren, Jean-Claude Dujardin, Malgorzata Anna Domagalska

Institute of Tropical Medicine, Antwerp, Belgium. Correspondence:
mdomagalska@itg.be, jcdujardin@itg.be

## What this deposit contains

This deposit holds the processed/intermediate data and the analysis scripts
behind every figure and table in the manuscript and its supplementary
information, comparing SuSL-seq (Agilent SureSelect target capture) and
SWGA-seq (selective whole-genome amplification) for direct sequencing of
*L. braziliensis* in clinical samples.

It does **not** contain the raw sequencing reads. Those are deposited under
NCBI BioProject **PRJNA1495770**
(https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA1495770), with
human-mapping reads removed prior to deposition, per the manuscript's data
availability statement.

- `zenodo_manifest.csv` - the authoritative index: one row per figure/table,
  with the exact path to its script(s) and input data inside the zip. **Start here.**
- `leishmania_susl_vs_swga_supplementary_data.zip` - the actual scripts and
  data, organized as two parallel trees:

  ```
  scripts/
  ├── 00_metadata/          
  ├── 01_swga_primer_design/
  ├── 02_mapping_and_coverage_qc/
  ├── 03_targeted_gene_coverage/
  ├── 04_somy_and_allele_frequency/
  ├── 05_phylogenomics_raxml_splitstree/
  └── 06_admixture_pcadmix/

  data/
  ├── 00_metadata/
  ├── 01_swga_primer_design/
  ├── 02_mapping_and_coverage_qc/
  ├── 03_targeted_gene_coverage/
  ├── 04_somy_and_allele_frequency/
  ├── 05_phylogenomics_raxml_splitstree/
  └── 06_admixture_pcadmix/
  ```

  The numbered topic name is the link between the two trees and the
  manifest's `topic_folder` column - a script and its data always share the
  same topic number, just under `scripts/` vs `data/`.


## How to cite

If you use this deposit, please cite the associated manuscript (citation to
be added once published/assigned a DOI) and, separately, this Zenodo record
via its own DOI.

## License

Data: CC-BY-4.0. Code: [choose - MIT or GPL-3.0, matching your group's usual
practice].

## Contact

Pieter Monsieurs, Institute of Tropical Medicine, Antwerp - pmonsieurs@itg.be
