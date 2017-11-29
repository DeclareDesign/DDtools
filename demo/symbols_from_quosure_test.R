example_quosure = quos(
month = level(
  new_var0 = rnorm(N)
),
month_ID = level(
  new_var1 = rnorm(N) + new_var0 + 5,
  new_var2 = pmax(0, sample(1:25, N, replace = TRUE) + new_var0 * 5)
)
)

begin_quos = quos(var_1 = rnorm(N) + var_2 + 5*sample(0:max_thing, N, replace=T),
                  var_2 = ((((j*3 + k)))),
                  var_3 = rnorm(N),
                  var_4 = pollution * 3)

get_symbols_from_expression = function(l_arg) {
  if(is.symbol(l_arg)) {
    return(unname(l_arg))
  } else if(is.language(l_arg)) {
    recurse = lang_args(l_arg)
    temp = unname(unlist(lapply(recurse, function(i) { process_lang_args(i) })))
    return(temp)
  } else {
  }
}

get_symbols_from_quosure = function(quosure) {
  meta_results =   lapply(quosure, function(i) {
    expression = get_expr(i)
    thing = lang_args(expression)
    results = lapply(thing, function(x) { get_symbols_from_expression(x) })
    return(unique(
      as.character(
        unlist(
          results))))
  })

  return(meta_results)
}

get_symbols_from_quosure(begin_quos)
get_symbols_from_quosure(example_quosure)
