library(tudrcafe)
library(readr)
library(dplyr)
library(here)
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
  filter(date >= now)

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
    image_loc <- paste0("img/posters/R_cafe_", 
                    upcoming[i,]$month_abbrev, 
                    upcoming[i,]$year, ".png")
    image <- paste0("/img/posters/R_cafe_", 
                    upcoming[i,]$month_abbrev, 
                    upcoming[i,]$year, ".png")
    upcoming_out[[i]] <- glue::glue_data(
      upcoming[i,],
      #template_vec
      #template_comb
      "
      - title: '{theme}'
        subtitle: '{theme_description}'
        description: {location}
        author: {presenter}
        date:  {date}
        time:  '{time}'
        path: {registration}
        ics: '{ics}'
        image: '{image}'
        
        
      "
    )
    # override file on first loop
    #if(i == 1) {
    #  write_lines(upcoming_out[[i]], "events/meetings/upcoming-meetings.yaml", append = F)
    #} else {
     # write_lines(upcoming_out[[i]], "events/meetings/upcoming-meetings.yaml", append = T)
    #}
    if (!file.exists(here(image_loc))){ 
      tudrcafe::update_poster(upcoming[i,], out_path ='img/posters/')
      }
      
    if (!file.exists(paste0("outlook/", upcoming[i,]$ics))){ 
      tudrcafe:::create_ical(upcoming[i,], 
                             paste0("outlook/", upcoming[i,]$ics))
    }
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
    - title: '{theme}'
      description: '{location}'
      author: '{presenter}'
      date:  {date}
      time:  '{time}'
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


