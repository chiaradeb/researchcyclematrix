#' Search RCM for terms and return the file id
#' @param search single string with search terms separated by a simple space. Search is not case sensitive. The best match will be returned. If there are multiple matches with the best match score, the user is prompted to select one.
#' @return the id as a string
#' @export
rcm_find_file.id<-function(rcm,search,unit=NULL){
  if(!is.null(unit)){
    rcm<-rcm[rcm$unit==unit,,drop=F]
  }
  search<-strsplit(search %>% tolower," ") %>% unlist
  found<-lapply(search,function(x){
    data.frame(in.rcid =  grepl(x,tolower(rcm$rcid)) %>% as.numeric*1000,
               in.file.id= grepl(x,tolower(rcm$file.id)) %>% as.numeric*100,
               in.round=grepl(x,tolower(rcm$round)) %>% as.numeric*10,
               in.type = grepl(x,tolower(rcm$type)) %>% as.numeric*1
    )

  }) %>% do.call(cbind,.)

  matchiness<-data.frame(matchiness=rowSums(found),id=1:nrow(found))
  matchiness<-matchiness[matchiness$matchiness!=0,]
  # matchiness<-matchiness[order(matchiness$matchiness,decreasing = T),]
  best_matches<-matchiness[matchiness$matchiness==max(matchiness$matchiness),"id"]
  matching_ids<-rcm[best_matches,"file.id"]
  if(length(matching_ids)==0){return(NULL)}
  if(length(matching_ids)==1){return(matching_ids)}

  selected<-readline(prompt = paste0(c("select by id:\n",paste0(
    1:length(matching_ids),": ",matching_ids)),collapse="\n")
  ) %>% as.numeric
  matching_ids[selected]

}

#' Search RCM for terms and return the row
#' @param search single string with search terms separated by a simple space. Search is not case sensitive. The best match will be returned. If there are multiple matches with the best match score, the user is prompted to select one.
#' @return the RCM row as a data frame with a single row
#' @export
rcm_find_row_by_file.id<-function(rcm,search,unit=NULL){
  id<-rcm_find_file.id(rcm,search = search,unit=unit)
  rcm[rcm$file.id==id,,drop=F]
}
