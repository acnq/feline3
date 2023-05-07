def hello := "world"
def bufsize : USize := 20 * 1024 -- USize is like size_t, unsigned integer

-- Concetenating Streams

-- streams
-- redirect standard input to standard output
partial def dump (stream : IO.FS.Stream) : IO Unit := do
  let buf ← stream.read bufsize
  if buf.isEmpty then 
    pure ()
  else
    (← IO.getStdout).write buf -- direct use dot after ← 
    -- nested actions
    dump stream  

-- open files and emit contents
def fileStream (filename : System.FilePath) : IO (Option IO.FS.Stream) := do 
  if not (← filename.pathExists) then 
    (←IO.getStderr).putStrLn s!"File not found: {filename}"
    pure none
  else 
    let handle ← IO.FS.Handle.mk filename IO.FS.Mode.read
    pure (some (IO.FS.Stream.ofHandle handle)) -- fill field of struct Stream with corspd IO actions

def help : IO Unit := do
  IO.println s!"Hello, use as echo something | ./build/bin/feline test1.txt - test2.txt"

-- handling Input
def process (exitCode : UInt32) (args : List String) : IO UInt32 := do
  match args with
  | [] => pure exitCode
  | "-" :: args =>
    let stdin ← IO.getStdin
    dump stdin
    process exitCode args
  | "--help" :: args => 
    help
    process exitCode args
  | filename :: args =>
    let stream ← fileStream (filename)
    match stream with 
    | none =>
      process 1 args
    | some stream =>
      dump stream 
      process exitCode args

def getNumA : IO Nat := do
  (← IO.getStdout).putStrLn "A"
  pure 5  

def getNumB : IO Nat := do
  (← IO.getStdout).putStrLn "B"
  pure 7

def test : IO Unit := do
  let a : Nat := if (← getNumA) == 5 then 0 else (← getNumB)
  (← IO.getStdout).putStrLn s!"The answer is {a}"

#eval test -- B's side effect has emerged

-- flexible layouts for do
def mouth : IO Unit := do 
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout

  stdout.putStrLn "How would you like to be addressed?"
  let name := (← stdin.getLine).trim
  stdout.putStrLn s!"Hello, {name}!"

-- as explicit as possible
def mouth' : IO Unit := do {
  let stdin ← IO.getStdin;
  let stdout ← IO.getStdout;

  stdout.putStrLn "How would you like to be addressed?";
  let name := (← stdin.getLine).trim;
  stdout.putStrLn s!"Hello, {name}!";
}
    
-- semicolon to put 2 actions on the same line
def mouth'' : IO Unit := do 
  let stdin ← IO.getStdin; let stdout ← IO.getStdout

  stdout.putStrLn "How would you like to be addressed?"
  let name := (←stdin.getLine).trim
  stdout.putStrLn s!"Hello, {name}!"
