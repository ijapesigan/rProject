.LibFormat <- function(type,
                       key,
                       fields) {
  # the house layout: @Type{Key, then one "  field = {value}," per line
  types <- c(
    article = "Article",
    book = "Book",
    collection = "Collection",
    inbook = "InBook",
    incollection = "InCollection",
    inproceedings = "InProceedings",
    manual = "Manual",
    misc = "Misc",
    online = "Online",
    report = "Report",
    thesis = "Thesis",
    phdthesis = "PhdThesis",
    mastersthesis = "MastersThesis",
    software = "Software",
    dataset = "Dataset",
    unpublished = "Unpublished"
  )
  # a type not in the list keeps its spelling
  house <- types[tolower(type)]
  type <- if (is.na(house)) type else unname(house)
  fields <- fields[!is.na(fields) & nzchar(trimws(fields))]
  names(fields) <- tolower(names(fields))
  lead <- c(
    "author", "editor", "bookauthor", "booktitle",
    "date", "journaltitle", "title", "subtitle"
  )
  trail <- c("abstract", "publisher", "keywords", "library", "annotation")
  middle <- sort(setdiff(names(fields), c(lead, trail)))
  order <- c(
    intersect(lead, names(fields)),
    middle,
    intersect(trail, names(fields))
  )
  c(
    paste0("@", type, "{", key, ","),
    paste0("  ", order, " = {", fields[order], "},"),
    "}"
  )
}
