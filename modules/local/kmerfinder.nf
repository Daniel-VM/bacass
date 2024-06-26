process KMERFINDER {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::kmerfinder=3.0.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kmerfinder:3.0.2--hdfd78af_0' :
        'biocontainers/kmerfinder:3.0.2--hdfd78af_0' }"

    input:
    tuple val(meta), path(reads), path(kmerfinder_db)

    output:
    tuple val(meta), path("*_results.txt")  , emit: report
    tuple val(meta), path("*_data.json")    , emit: json
    path "versions.yml"                     , emit: versions

    script:
    def prefix   = task.ext.prefix ?: "${meta.id}"
    def in_reads = reads[0] && reads[1] ? "${reads[0]} ${reads[1]}" : "${reads}"
    // WARNING: Ensure to update software version in this line if you modify the container/environment.
    def kmerfinder_version = "3.0.2"
    """
    kmerfinder.py \\
        --infile $in_reads \\
        --output_folder . \\
        --db_path ${kmerfinder_db}/bacteria.ATG \\
        -tax ${kmerfinder_db}/bacteria.name \\
        -x

    mv results.txt ${prefix}_results.txt
    mv data.json ${prefix}_data.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kmerfinder: \$(echo "${kmerfinder_version}")
    END_VERSIONS
    """
}
