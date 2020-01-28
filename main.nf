#!/usr/bin/env nextflow 

//load query dataset
INPUT_DATA = Channel.fromPath(params.input_data)

process read_input_data{
	//publishDir "${baseDir}/output", mode: 'copy'
	//cacheDir = params.conda.cacheDir
    	conda "${baseDir}/envs/dropletutils.yaml"
    	
    	errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    	maxRetries 5
    	memory { 8.GB * task.attempt }
    	
    	input: 
    	file(input_data) from INPUT_DATA

    	output:
    	file("input_sce.rds") into INPUT_SCE

    	"""
    	dropletutils-read-10x-counts.R\
    	        --samples ${input_data}\
    	        --col-names ${params.col_names}\
    	        --output-object-file input_sce.rds
    	"""
}

// calculate QC metrics

process calculate_QC_metrics {
	
	publishDir "${baseDir}/output", mode: 'copy'
	//cacheDir = params.conda.cacheDir
    	conda "${baseDir}/envs/scater.yaml"
    	
    	errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    	maxRetries 5
    	memory { 8.GB * task.attempt }

    	input: 
    	file(input_sce) from INPUT_SCE

    	output:
    	file("sce_qc_metrics.rds") into QC_MECTRICS_SCE

    	"""
    	scater-calculate-qc-metrics.R\
    	        --input-object-file ${input_sce}\
    	        --output-object-file sce_qc_metrics.rds
    	"""
}

// scater filter

process scater_filter {
    	publishDir "${baseDir}/output", mode: 'copy'
    	conda "${baseDir}/envs/scater.yaml"
    	errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    	maxRetries 5
    	memory { 8.GB * task.attempt }

    	input: 
    	file(metrics_sce) from QC_MECTRICS_SCE

    	output:
    	file("filter_sce.rds") into NORM_SCE

    	"""
    	scater-filter.R\
    	        --input-object-file ${metrics_sce}\
    	        --output-object-file filter_sce.rds
    	"""
}
// scater normalize

process scater_normalize {
    	publishDir "${baseDir}/output", mode: 'copy'
    	conda "${baseDir}/envs/scater.yaml"
    	errorStrategy { task.attempt < 5  ? 'retry' : 'finish' }   
    	maxRetries 5
    	memory { 8.GB * task.attempt }

    	input: 
    	file(filter_sce) from NORM_SCE

    	output:
    	file("norm_sce.rds") into CELLASSIGN

    	"""
    	scater-filter.R\
    	        --input-object-file ${filter_sce}\
    	        --output-object-file norm_sce.rds
    	"""
}


//load marker gene file


