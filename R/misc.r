
.onLoad <- function (libname, pkgname) {
    utils::globalVariables(c("oautoexec","hook_orig")) # to suppress CHECK note
}

.onAttach <- function (libname, pkgname) {
    knitr::knit_engines$set(sas=saslog, saslog=saslog, 
                            sashtml=sashtml, sashtmllog=sashtml,
                            sashtml5=sashtml, sashtml5log=sashtml)

    knitr::opts_hooks$set(results = function(options) {
        if (options$engine %in% c("sashtml", "sashtmllog", "sashtml5", "sashtml5log") &&
            options$results != "hide") {
            options$results = "asis"
        }
            options
    })
    
    sas_collectcode()
    # saslog_hookset()
    
    sasexe <- find_sas()
    if (!is.null(sasexe)) {
        knitr::opts_chunk$set(engine.path=list(sas=sasexe,
                    saslog=sasexe, sashtml=sasexe, sashtmllog=sasexe,
                    sashtml5=sasexe, sashtml5log=sasexe))
    }
    sasopts <- "-nosplash -ls 75"
    knitr::opts_chunk$set(engine.opts=list(sas=sasopts,
                    saslog=sasopts, sashtml=sasopts, sashtmllog=sasopts,
                    sashtml5=sasopts, sashtml5log=sasopts))
    knitr::opts_chunk$set(error=TRUE, comment=NA)
    
    knitr::knit_hooks$set(source = function(x, options) {
        if (!is.null(options$hilang)) {
            textarea_id <- paste(sample(LETTERS, 5), collapse = "")
            code_open <- paste0("\n\n<textarea id=\"", textarea_id, "\">\n")
            code_close <- "\n</textarea>"
            jscript_editor <- paste0("\n<script> var codeElement = document.getElementById(\"", textarea_id, "\"); var editor = null; if (null != codeElement) { editor = CodeMirror.fromTextArea(codeElement, { lineNumbers: true, readOnly: true, viewportMargin: Infinity, mode: 'text/x-", tolower(options$hilang), "' }); } </script>\n")
            
            # if the option from_file is set to true then assume that
            #   whatever is in the code chunk is a file path
            if (!is.null(options$from_file) && options$from_file) {
                code_body <- readLines(file.path(x))   
            } else {
                code_body <- x
            }
            
            knitr::asis_output(
                htmltools::htmlPreserve(
                    stringr::str_c(
                        code_open,
                        paste(code_body, collapse = "\n"),
                        code_close,
                        jscript_editor
                    )
                )
            )
        } else {
            stringr::str_c("\n\n```", tolower(options$engine), "\n", paste(x, collapse = "\n", "\n```\n\n"))
        }
    })
    
    knitr::set_header(highlight = "<link rel=\"stylesheet\" href=\"inst/lib/codemirror.css\">\n<script src=\"inst/lib/codemirror.js\"></script>\n<script src=\"inst/mod/sas.js\"></script>\n<style>.CodeMirror {\nborder: 1px solid #eee;\nheight: auto;\n}\n</style>") 

    packageStartupMessage("sas, saslog, sashtml, sashtml5, and sashtmllog & sashtml5log engines")
    packageStartupMessage("   are now ready to use.")
}
