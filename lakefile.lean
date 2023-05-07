import Lake
open Lake DSL

package feline3 {
  -- add package configuration options here
}

lean_lib Feline3 {
  -- add library configuration options here
}

@[default_target]
lean_exe feline3 {
  root := `Main
}
