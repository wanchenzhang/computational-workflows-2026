<<<<<<< HEAD
params.step = "0"
params.zip = 'zip'
=======
params {
    step: Integer = 0
    zip: String = 'zip'
}
>>>>>>> upstream/main


process SAYHELLO {
    debug true
    script:
    """
    echo 'Hello World!'
    """
}

process SAYHELLO_PYTHON {
    debug true

    script:
    """
    python3 -c "print('Hello World!')"
    """
}

process SAYHELLO_PARAM {
    debug true

    input:
    val greeting

    script:
    """
    echo '${greeting}'
    """
}

process SAYHELLO_FILE {
    publishDir "${projectDir}/results", mode: 'copy', overwrite: true

    input:
    val greeting

    output:
    path 'greeting.txt'

    script:
    """
    printf '%s\\n' '${greeting}' > greeting.txt
    """
}

process UPPERCASE {
    publishDir "${projectDir}/results", mode: 'copy', overwrite: true
    input:
    val greeting

    output:
    path 'uppercase.txt'

    script:
    """
    printf '%s\\n' '${greeting}' | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

process PRINTUPPER {
    debug true

    input:
    path text_file

    script:
    """
    cat '${text_file}'
    """
}


process COMPRESS {
    input:
    tuple val(format), path(text_file)

    output:
    path "${text_file}.${format == 'gzip' ? 'gz' : format == 'bzip2' ? 'bz2' : 'zip'}"

    script:
    if (format == 'zip') {
        """
        zip '${text_file}.zip' '${text_file}'
        """
    } else if (format == 'gzip') {
        """
        gzip -c '${text_file}' > '${text_file}.gz'
        """
    } else if (format == 'bzip2') {
        """
        bzip2 -c '${text_file}' > '${text_file}.bz2'
        """
    } else {
        error "Unsupported compression format: ${format}"
    }
}


process WRITETOFILE {
    publishDir 'results', mode: 'copy', overwrite: true

    input:
    val people

    output:
    path 'names.tsv'

    script:
    def rows = people.collect { person ->
        "${person.name}\t${person.title}"
    }.join('\n')

    """
    cat > names.tsv <<'EOF'
name\ttitle
${rows}
EOF
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == "1") {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == "2") {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == "3") {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == "4") {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == "5") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == "6") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == "7") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        compression_ch = out_ch.map { text_file ->
        tuple(params.zip.toString(), text_file)
    }

    COMPRESS(compression_ch).view()
    }


    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == "8") {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)

        formats_ch = channel.of('zip', 'gzip', 'bzip2')
        compression_ch = formats_ch.combine(out_ch)

        COMPRESS(compression_ch).view()

    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == "9") {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
        people_ch = in_ch.collect(flat: false)
        WRITETOFILE(people_ch).view()
    }

}