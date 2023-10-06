## Introduction

**nf-pipelines** is a minimal nf-core pipeline containing as few components as possible. The idea is to be as light as possible while maintaining compatibility with nf-core tools such as modules and subworkflows. You could use this as a template to start your own pipeline or explore alternative methods of working with the nf-core template. 

## Overview

This pipeline uses a samplesheet input, then runs any modules or subworkflows in the `NFPIPELINE` workflow in `main.nf` before completing. As a brief set of instructions, you can add any Nextflow process or workflow within the `NFPIPELINE` block and execute it. We include the `MULTIQC` as an example and generate a report for quality control metrics.

## Template instructions

## Make your own repo

### Add the repo to your organisation

- [ ] Fork the repo to your own organisation and change the name to something appropriate

### Template Naming

- [ ] Replace all instances of `nf-pipelines` with the name of your pipeline
- [ ] Replace all instances of `seqeralabs` with your GitHub username/organization
- [ ] Run `nf-core lint` to check you have found all references to seqeralabs/nf-pipelines

### Samplesheet handling

- [ ] Update the `assets/schema_input.json` for your own samplesheet. The samplesheet currently uses a forward and reverse FASTQ with an additional `meta_value`, which could represent any sample specific information such as treatment, but you will need to update this for your use case. Use the [nf-validate documentation](https://nextflow-io.github.io/nf-validation/nextflow_schema/sample_sheet_schema_specification/) to guide you.

### Add needed modules/processes

For each module or subworkflow you would like to run, you will need to do one of the following:

- [ ] Add any needed nf-core modules via the cli command `nf-core modules install`
- [ ] Add any custom processes to the `modules/local` directory

Then do the following steps:

### Modify the main workflow

- [ ] Modify the `main.nf` file to add any needed processes

### Modify the configuration

- [ ] Add any new parameters to the nextflow.config
- [ ] Each nf-core module uses a task.ext.args for configuring tool parameters. Update these using a configuration item in `nextflow.config`. MULTIQC has been included as an example, but you can also add these in additional configuration files [but you must make sure to import them](https://www.nextflow.io/docs/latest/config.html?highlight=includeconfig#config-include):

```nextflow
process {
   withName: 'MULTIQC' {
      ext.args = "--force --verbose"
   }
}
```

### Documentation

- [ ] Use `nf-core schema build` to build the pipeline parameters and validation. This builds the argument documentation automatically!
- [ ] Update the documentation so future users can see how to run the pipeline. Include the purpose of the pipeline, instructions on how to use it, how to make the samplesheet and what to expect as outputs.

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Now, you can run the pipeline using:

```bash
nextflow run seqeralabs/nf-pipelines \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv
```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Background

This format was inspired by [kenibrewer/simplenextflow](https://github.com/kenibrewer/simplenextflow) but it has the following differences:

- It is generated using the template and should be compatible with `nf-core sync` for the foreseeable future
- It uses the `nf-validate` plugin to reduce boilerplate code
- It uses the `INITIALISE` subworkflow to remove _even more_ boilerplate code
- It removes some additional files such as `docs/`
- It uses Nextflow code to replace the Java classes in `lib/` (see [the initialise subworkflow](./subworkflows/local/initialise.nf))
- It uses `results` as a default value for `--outdir` to remove one additional parameter user need to supply
- It removes email and slack integration for simplicity
- It removes Github features so developers can add their own

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
