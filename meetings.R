library(tudrcafe)
library(readr)
library(dplyr)
sched <- tudrcafe:::retrieve_schedule()

sessions <- tudrcafe:::parse_schedule(sched)

template <- read_lines("meetings-template")
template_comb <- paste0("", template, collapse = "\n")
sessions_parsed <- sessions |>
  mutate(
    title = paste0("R Cafe ", month_name),
    presenter = stringr::str_replace(presenter, ";", " & "),
    ics = paste0("Rcafe-", tolower(month_abbrev), year, ".ics")
  )

now <- Sys.Date()

upcoming <- sessions_parsed |>
  filter(date > now)

past <- sessions_parsed |>
  filter(date < now)

if(nrow(upcoming) == 0){
  out <- c(
    "
    - title: TBD
    "
  )
  write_lines(out, "events/meetings/upcoming-meetings.yaml")
} else {
  upcoming_out <- vector(mode = "list", length = nrow(upcoming))
  for (i in 1:nrow(upcoming)) {
    upcoming_out[[i]] <- glue::glue_data(
      upcoming[i,],
      #template_vec
      #template_comb
      "
      - title: '{title}'
        subtitle: '{theme}'
        description: {location}
        author: {presenter}
        date:  {date}
        path: {registration}
        ics: '{ics}'
      "
    )
    # override file on first loop
    #if(i == 1) {
    #  write_lines(upcoming_out[[i]], "events/meetings/upcoming-meetings.yaml", append = F)
    #} else {
     # write_lines(upcoming_out[[i]], "events/meetings/upcoming-meetings.yaml", append = T)
    #}
  }
  write_lines(upcoming_out, "events/meetings/upcoming-meetings.yaml", append = F)
}


past_out <- vector(mode = "list", length = nrow(past))
for (i in 1:nrow(past)) {
  past_out[[i]] <- glue::glue_data(
    past[i,], 
    #template_comb
    #template_vec
    "
    - title: '{title}'
      subtitle: '{theme}'
      description: '{location}'
      author: '{presenter}'
      date:  {date}
      path: {resource_url}
    "
  )
  # override file on first loop
  if(i == 1) {
    write_lines(past_out[[i]], "events/meetings/past-meetings.yaml", append = F)
  } else {
    write_lines(past_out[[i]], "events/meetings/past-meetings.yaml", append = T)
  }
}

