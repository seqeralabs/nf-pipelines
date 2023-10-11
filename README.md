## Introduction

**nf-pipelines** is a minimal nf-core pipeline containing as few components as possible. The idea is to be as light as possible while maintaining compatibility with nf-core tools such as modules and subworkflows. You could use this as a template to start your own pipeline or explore alternative methods of working with the nf-core template.

## Overview

This pipeline uses a samplesheet input, then runs the GATK/Picard tool to compare samples and check for a sample mix up. It takes a samplesheet of BAM files as input, removes duplicate reads then compares those files at the locations provided by the `--haplotype_map` parameter. Finally it produces a report with MultiQC for summarising and interpreting the results.

### Required Inputs

- `input`: Path to samplesheet which must contain the columns `sample` and `bam`. Each BAM file is expected to have an index file located at the same path with additional extension `.bai`.
- `fasta`: Path to FASTA genome file.
- `dict`: Path to GATK/Picard dictionary file. If missing it can be created with [GATK CreateSequenceDictionary](https://gatk.broadinstitute.org/hc/en-us/articles/360037422891-CreateSequenceDictionary-Picard-).
- `haplotype_map`: A path to the haplotype map used by [GATK/Picard CrossCheckFingerprints](https://gatk.broadinstitute.org/hc/en-us/articles/9570489180699-CrosscheckFingerprints-Picard-) and GATK/Picard ExtractFingerprint.
- `outdir`: Path to output directory. The output files will be added here during the pipeline run.

### Optional Inputs

- `fai`: Path to genome FASTA index, if not supplied, this will be assumed to be located at the path to the FASTA file plus the additional extension `.fai`.

### Parameters

- `--expect_all_to_match`: Expects all samples to match when comparing samples. Otherwise it will only check matching sample IDs. Defaults to true, turn off with `--expect_all_to_match false`.
- `--error_when_mismatch`: If true, the pipeline will raise an error if any samples expected to match do not. If not, the pipeline will continue and generate a report. Defaults to off, turn on with `--error_when_mismatch`.
- `lod_threshold`: The LOD score threshold when mismatching. Defaults to -5 but can be set to any number.
- `tumor_aware`: Perform the calculations assuming samples contain tumor mutational data. Defaults to off, turn on with `--tumor_aware`.
- `crosscheck_by`: Make comparisons on a per-file basis or per-sample. Since all VCF files contain 1 sample, these are equivalent. Defaults to `FILE` but `SAMPLE` is also a valid option.

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,bam
CONTROL_REP1,control_rep1.bam
```

To run from a remote version, use the command:

```bash
nextflow run seqeralabs/nf-pipeline \
   -r gatk_fingerprint \
   --input /path/to/samplesheet.csv \
   --fasta /path/to/genome.fasta \
   --haplotype_map /path/to/haplotype-map.txt \
   --dict /path/to/genome.dict
```

Remember if these files are remote to supply them with the Nextflow file operators, e.g. for AWS S3:

```bash
nextflow run seqeralabs/nf-pipeline \
   -r gatk_fingerprint \
   --input 's3://path/to/samplesheet.csv' \
   --fasta 's3://path/to/genome.fasta' \
   --haplotype_map 's3://path/to/haplotype-map.txt' \
   --dict 's3://path/to/genome.dict'
```

A help command is provided to assist in running the pipeline and can be accessed with `nextflow run seqeralabs/nf-pipeline --help`.

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

seqeralabs/nf-pipelines was originally written by the scidev team and Seqeralabs.

## Contributions and Support

If you would like to contribute to this pipeline, please open an issue or pull request.

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
