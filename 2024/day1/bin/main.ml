let print_file file_name = begin
  let ic = open_in file_name in
  try
    while true do
      let line = input_line ic in
      print_endline line      
    done
  with _ ->
    close_in_noerr ic
end

let _ = print_file "data/sample.txt"