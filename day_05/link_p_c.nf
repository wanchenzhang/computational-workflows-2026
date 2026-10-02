#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
    tuple val(meta), val(input_str), val(out_name)

    output:
    tuple val(meta), path("${out_name}_*.txt")

    script:
    // Encode the input to safely pass it to Python
    def encoded = input_str.bytes.encodeBase64().toString()

    """
    python3 - <<'PY'
import base64
from pathlib import Path

text = base64.b64decode("${encoded}").decode("utf-8")
block_size = ${meta.block_size}
prefix = "${out_name}"

if block_size <= 0:
    raise ValueError("block_size must be greater than zero")

for index, start in enumerate(range(0, len(text), block_size), start=1):
    chunk = text[start:start + block_size]
    Path(f"{prefix}_{index:03d}.txt").write_text(chunk, encoding="utf-8")
PY
    """
} 

process CONVERTTOUPPER {
    debug true

    publishDir "${projectDir}/results", mode: 'copy', overwrite: true

    input:
    path chunk_file

    output:
    path "upper_${chunk_file.name}"

    script:
    """
    tr '[:lower:]' '[:upper:]' < '${chunk_file}' > 'upper_${chunk_file.name}'
    cat 'upper_${chunk_file.name}'
    printf '\\n'
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    in_ch = channel
        .fromPath('samplesheet_2.csv', checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                [block_size: row.block_size.toInteger()],
                row.input_str,
                row.out_name
            )
        }
    // split the input string into chunks
    split_ch = SPLITLETTERS(in_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    chunk_ch = split_ch
        .map { meta, files -> files }
        .flatten()
    chunk_ch.view { file -> "Chunk file: ${file}" }
    // convert the chunks to uppercase and save the files to the results directory
    
    CONVERTTOUPPER(chunk_ch)


}