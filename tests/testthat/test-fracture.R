expect_comparable <- function(object, expected, ...) {
  testthat::expect_equal(object, expected, ..., ignore_attr = TRUE)
}

test_that("scalar fracture()", {
  expect_comparable(fracture(0.5), "1/2")
  expect_comparable(as.fracture(0.5), "1/2")
  expect_comparable(fracture(355/113), "355/113")
  expect_comparable(as.fracture(355/113), "355/113")
})

test_that("big fracture()", {
  expect_comparable(fracture((1e4 - 1) / 1e5), "9999/100000")
  expect_comparable(as.fracture((1e4 - 1) / 1e5), "9999/100000")
})

test_that("small fracture()", {
  expect_comparable(fracture(1 / 1e5), "1/100000")
  expect_comparable(as.fracture(1 / 1e5), "1/100000")
})

test_that("extreme fracture()", {
  expect_comparable(fracture(0), "0/1")
  expect_comparable(fracture(.Machine$double.eps), "0/10000000")
  expect_comparable(fracture(1), "1/1")
  expect_comparable(fracture(1 - .Machine$double.eps), "10000000/10000000")

  expect_comparable(
    fracture(
      c(0, .Machine$double.eps, 1/5, 1 - .Machine$double.eps, 1),
      common_denom = TRUE
    ),
    c("0/5", "0/5", "1/5", "5/5", "5/5")
  )
})

test_that("irrational fracture()", {
  expect_comparable(fracture(pi, max_denom = 100), "22/7")
})

test_that("vector fracture()", {
  expect_comparable(fracture(c(0.5, 0.75, 2/3)), c("1/2", "3/4", "2/3"))
  expect_comparable(as.fracture(c(0.5, 0.75, 2/3)), c("1/2", "3/4", "2/3"))
})

test_that("long vector fracture()", {
  withr::local_options(list(scipen = 1000))

  x <- expand.grid(
    c(1:100, sample(100:1e7, 100)), c(1:100, sample(100:1e7, 100))
  )

  test_decimal  <- x[, 1] / x[, 2]
  unique        <- match(unique(test_decimal), test_decimal)
  test_decimal  <- test_decimal[unique]

  x   <- x[unique, ]
  gcd <- apply(x, 1, frac_gcd)
  x   <- x / gcd

  test_fraction <- paste(x[, 1], x[, 2], sep = "/")

  expect_comparable(fracture(test_decimal), test_fraction)
})

test_that("really long vector fracture()", {
  skip_on_cran()
  withr::local_options(list(scipen = 1000))

  x <- expand.grid(
    c(1:1000, sample(1000:1e7, 1000)), c(1:1000, sample(1000:1e7, 1000))
  )

  test_decimal  <- x[, 1] / x[, 2]
  unique        <- match(unique(test_decimal), test_decimal)
  test_decimal  <- test_decimal[unique]

  x   <- x[unique, ]
  gcd <- apply(x, 1, frac_gcd)
  x   <- x / gcd

  test_fraction <- paste(x[, 1], x[, 2], sep = "/")

  expect_comparable(fracture(test_decimal), test_fraction)
})

test_that("explicit denom fracture()", {
  expect_comparable(fracture(2 / 11, denom = 10), "2/10")
  expect_comparable(
    fracture(rep(2 / 11, 2), denom = c(10, 12)), c("2/10", "2/12")
  )
  expect_comparable(
    fracture(24 / 11, denom = 10, mixed = TRUE), "2 2/10"
  )
  expect_comparable(
    fracture(c(6, 20) / 11, denom = 10, mixed = TRUE), c("5/10", "1 8/10")
  )
})

test_that("improper fracture()", {
  expect_comparable(fracture(c(1.5, 2)), c("3/2", "2/1"))
  expect_comparable(as.fracture(c(1.5, 2)), c("3/2", "2/1"))
})

test_that("negative fracture()", {
  expect_comparable(fracture(-0.5), "-1/2")
  expect_comparable(as.fracture(-0.5), "-1/2")
})

test_that("base_10 fracture()", {
  expect_comparable(fracture(0.5, base_10 = TRUE), "5/10")
  expect_comparable(fracture(1307.36, base_10 = TRUE), "130736/100")
})

test_that("really long base_10 fracture()", {
  withr::local_options(list(scipen = 1000))

  x <- expand.grid(c(1:100, sample(100:1e7, 100)), 10 ^ (0:7))

  test_decimal  <- x[, 1] / x[, 2]
  unique        <- match(unique(test_decimal), test_decimal)
  test_decimal  <- test_decimal[unique]

  x   <- x[unique, ]
  gcd <- apply(x, 1, frac_gcd)
  x   <- x / gcd

  test_fraction <- paste(x[, 1], x[, 2], sep = "/")

  expect_comparable(fracture(test_decimal), test_fraction)
})

test_that("really long base_10 fracture()", {
  skip_on_cran()
  withr::local_options(list(scipen = 1000))

  x <- expand.grid(c(1:1e4, sample(1e4:1e7, 1e4)), 10 ^ (0:7))

  test_decimal  <- x[, 1] / x[, 2]
  unique        <- match(unique(test_decimal), test_decimal)
  test_decimal  <- test_decimal[unique]

  x   <- x[unique, ]
  gcd <- apply(x, 1, frac_gcd)
  x   <- x / gcd

  test_fraction <- paste(x[, 1], x[, 2], sep = "/")

  expect_comparable(fracture(test_decimal), test_fraction)
})

test_that("common_denom fracture()", {
  expect_comparable(
    fracture(c(0.5, 0.75, 2/3), common_denom = TRUE), c("6/12", "9/12", "8/12")
  )
})

test_that("mixed fracture()", {
  expect_comparable(
    fracture(c(1.5, 0.5, 1), mixed = TRUE), c("1 1/2", "1/2", "1")
  )
})

test_that("mixed negative fracture()", {
  expect_comparable(fracture(c(-0.5, -4/3), mixed = TRUE), c("-1/2", "-1 1/3"))
})

test_that("max_denom fracture()", {
  expect_comparable(fracture(pi, max_denom = 100),  "22/7")
  expect_comparable(fracture(pi, max_denom = 1000), "355/113")
})

test_that("base_10 max_denom fracture()", {
  expect_comparable(
    fracture(c(1/2, 1/3, 1/4), base_10 = TRUE, max_denom = 1000),
    c("5/10", "333/1000", "25/100")
  )
})

test_that("base_10 common_denom max_denom fracture()", {
  expect_comparable(
    fracture(
      c(1/2, 1/3, 1/4), base_10 = TRUE, common_denom = TRUE, max_denom = 1000
    ),
    c("500/1000", "333/1000", "250/1000")
  )
})

test_that("epsilon without common_denom fracture()", {
  expect_comparable(
    fracture(c(1e-10, 1 - 1e-10), max_denom = 100), c("0/100", "100/100")
  )
})

test_that("epsilon with common_denom fracture()", {
  expect_comparable(
    fracture(c(1e-10, 1 - 1e-10, 1/3), common_denom = TRUE),
    c("0/3", "3/3", "1/3")
  )
})

test_that("big max_denom fracture()", {
  expect_warning(fracture(0.5, max_denom = 1e10))
})

test_that("as.fracture() from frac_mat()", {
  expect_equal(as.fracture(frac_mat(0.5)), fracture(0.5))
  expect_equal(
    as.fracture(frac_mat(c(0.5, 0.75, 2/3))), fracture(c(0.5, 0.75, 2/3))
  )
  expect_equal(as.fracture(frac_mat(c(1.5, 2))), fracture(c(1.5, 2)))
  expect_equal(
    as.fracture(frac_mat(0.5, base_10 = TRUE)), fracture(0.5, base_10 = TRUE)
  )
  expect_equal(
    as.fracture(frac_mat(c(0.5, 0.75, 2/3), common_denom = TRUE)),
    fracture(c(0.5, 0.75, 2/3), common_denom = TRUE)
  )
  expect_equal(
    as.fracture(frac_mat(c(1.5, 0.5, 1), mixed = TRUE)),
    fracture(c(1.5, 0.5, 1), mixed = TRUE)
  )
  expect_equal(
    as.fracture(frac_mat(c(-0.5, -4/3), mixed = TRUE)),
    fracture(c(-0.5, -4/3), mixed = TRUE)
  )
  expect_equal(
    as.fracture(frac_mat(pi, max_denom = 100)), fracture(pi, max_denom = 100)
  )
  expect_equal(
    as.fracture(frac_mat(pi, max_denom = 1000)), fracture(pi, max_denom = 1000)
  )
  expect_equal(
    as.fracture(frac_mat(c(1/2, 1/3, 1/4), base_10 = TRUE, max_denom = 1000)),
    fracture(c(1/2, 1/3, 1/4), base_10 = TRUE, max_denom = 1000)
  )
  expect_equal(
    as.fracture(
      frac_mat(
        c(1/2, 1/3, 1/4), base_10 = TRUE, common_denom = TRUE, max_denom = 1000
      )
    ),
    fracture(
      c(1/2, 1/3, 1/4), base_10 = TRUE, common_denom = TRUE, max_denom = 1000
    )
  )
  expect_equal(
    as.fracture(frac_mat(c(1e-10, 1 - 1e-10), max_denom = 100)),
    fracture(c(1e-10, 1 - 1e-10), max_denom = 100)
  )
  expect_equal(
    as.fracture(frac_mat(c(1e-10, 1 - 1e-10, 1/3), common_denom = TRUE)),
    fracture(c(1e-10, 1 - 1e-10, 1/3), common_denom = TRUE)
  )
})

frac_half <- fracture(0.5)

test_that("is.fracture()", {
  expect_true(is.fracture(frac_half))
  expect_true(is.fracture(as.fracture(0.5)))
})

test_that("as.character.fracture()", {
  chr <- as.character(frac_half)
  expect_equal(chr, "1/2")
  expect_type(chr, "character")
})

test_that("as.numeric.fracture()", {
  num <- as.numeric(frac_half)
  expect_equal(num, 0.5)
  expect_type(num, "double")
})

test_that("as.double.fracture()", {
  dbl <- as.double(frac_half)
  expect_equal(dbl, 0.5)
  expect_type(dbl, "double")
})

test_that("as.integer.fracture()", {
  int <- as.integer(frac_half)
  expect_equal(int, 0)
  expect_type(int, "integer")
})

test_that("print.fracture()", {
  expect_output(print(frac_half), "1/2")
})

test_that("Math.fracture()", {
  expect_comparable(abs(fracture(-0.5)), "1/2")
  expect_comparable(log(fracture(0.5), 4), "-1/2")
})

test_that("Ops.fracture()", {
  expect_comparable(fracture(0.5) * 3, "3/2")
  expect_comparable(3 * fracture(0.5), "3/2")
  expect_comparable(fracture(0.5) + 1, "3/2")
  expect_comparable(1 + fracture(0.5), "3/2")
  expect_comparable(fracture(0.5) * fracture(0.5), "1/4")
  expect_comparable(fracture(0.5) + fracture(0.25), "3/4")
  expect_comparable(fracture(0.5) + TRUE, "3/2")
  expect_comparable(TRUE + fracture(0.5), "3/2")
  expect_comparable(1i + fracture(0.5), 0.5 + 1i)
  expect_comparable(fracture(0.5) + 1i, 0.5 + 1i)
  expect_true(fracture(0.5) == "1/2")
  expect_true("1/2" == fracture(0.5))
  expect_true(fracture(0.5) == 0.5)
  expect_true(0.5 == fracture(0.5))
  expect_true(fracture(0.5) > 0)
  expect_true(0 < fracture(0.5))
  expect_true(fracture(1) == TRUE)
  expect_true(TRUE == fracture(1))
  expect_true(fracture(0) | TRUE)
  expect_true(TRUE | fracture(0))
  expect_false(fracture(0) & TRUE)
  expect_false(TRUE & fracture(0))
  expect_true(fracture(1.5) == fracture(1.5, base_10 = TRUE))
  expect_true(fracture(1.5) == fracture(1.5, mixed = TRUE))
  expect_false(is.na(fracture(0.5)))
  expect_length(fracture(0.5) + NULL, 0)
  expect_length(NULL + fracture(0.5), 0)

  expect_comparable(fracture(c(0.5, 1.5)) + 1, c("3/2", "5/2"))
})

test_that("recover_fracture_args()", {
  expect_null(recover_fracture_args(0, 0))
})

test_that("non-finite fracture()", {
  expect_comparable(fracture(NA), NA)
  expect_comparable(fracture(c(0.5, NA, 1.5)), c("1/2", NA, "3/2"))

  expect_comparable(fracture(Inf), "Inf/1")
  expect_comparable(fracture(-Inf), "-Inf/1")

  expect_comparable(fracture(Inf,  mixed = TRUE), "Inf")
  expect_comparable(fracture(-Inf, mixed = TRUE), "-Inf")
})

test_that("early returns", {
  expect_equal(fracture(numeric(0)), numeric(0))
  expect_equal(fracture(NA), NA)
  expect_equal(fracture(NA, mixed = TRUE), NA)
})

test_that("fracture() errors", {
  expect_error(fracture(character(1)))
  expect_error(fracture(1, denom = NA))
  expect_error(fracture(1, denom = Inf))
  expect_error(fracture(1, denom = 1:2))
  expect_error(fracture(1:10, denom = 1:2))
})
