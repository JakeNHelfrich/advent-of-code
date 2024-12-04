let () =
  let input_chan = open_in "data/sample.txt" in 
  try
    let line = input_line input_chan in
    print_endline line;
  with _ ->
    close_in_noerr input_chan;