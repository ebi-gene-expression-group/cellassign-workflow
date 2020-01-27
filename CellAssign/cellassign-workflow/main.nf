#!/usr/bin/env nextflow 

//load query dataset
INPUT_DATA = Channel.fromPath(params.input_data)

process read_input_data{
     conda "${baseDir}/envs/dropletutils.yaml"
    
    errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    maxRetries 5
    memory { 8.GB * task.attempt }
    
    input: 
    file(input_data) from INPUT_DATA

    output:
    file("sce.rds") into INPUT_SCE

    """
    dropletutils-read-10x-counts.R\
            --samples ${input_data}\
            --col-names ${params.col_names}\
            --output-object-file sce.rds
    """
}
// calculate QC metrics
process calculate_QC_metrics {
    conda "${baseDir}/envs/scater.yaml"
    errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    maxRetries 5
    memory { 8.GB * task.attempt }

    input: 
    file(input_sce) from INPUT_SCE

    output:
    file("sce.rds") into QC_MECTRICS_SCE

    """
    scater-calculate-qc-metrics.R
            --input-object-file ${input_sce}
            --output-object-file sce.rds

    """
}

// scater filter


// scater normalize



//load marker gene file


