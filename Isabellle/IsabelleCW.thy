theory IsabelleCW imports Complex_Main begin

find_theorems "_ \<in> \<rat>"
thm Rats_abs_nat_div_natE

find_theorems "(_/_)^_"
thm power_divide

find_theorems "_ \<in> \<rat>"
thm Rats_inverse

thm nonzero_eq_divide_eq

section \<open> Task 1 \<close>

theorem sqrt2_irrational : "sqrt  2 \<notin> \<rat>"
proof auto
  assume "sqrt 2 \<in> \<rat>"
  then obtain m n where
    " n \<noteq> 0" and "\<bar>sqrt 2\<bar> = real m / real n" and "coprime m n"
    by (rule Rats_abs_nat_div_natE)
  hence "\<bar>sqrt 2\<bar>^2 = (real m / real n)^2" by simp
  hence "2 = (real m / real n)^2" by simp
  hence "2 = (real m)^2 / (real n)^2" unfolding power_divide by simp
  hence "2 * (real n)^2 = (real m)^2" by (simp add: nonzero_eq_divide_eq `n \<noteq> 0`)
  hence "real (2*n^2) = real (m^2)" by simp
  hence *:"2*n^2 = m^2" by linarith
  hence "even (m^2)" by presburger
  hence "even m" by simp
  then obtain m' where "m=2*m'" by auto
  with * have "2*n^2 = (2*m')^2" by auto
  hence "n^2 = 2*m'^2" by auto
  hence "even (n^2)" by presburger
  hence "even n" by simp
  with `even m` and `coprime m n` show False by auto
qed



theorem Task1 : "3 / sqrt 2 \<notin> \<rat>"
proof auto 
  assume "3 / sqrt 2 \<in> \<rat>"
  hence "inverse ( 3/ sqrt 2) \<in> \<rat>" by (rule Rats_inverse)
  hence "sqrt 2 / 3 \<in> \<rat>" by simp
  then obtain m n where 
    " n \<noteq> 0"  and "\<bar>sqrt 2 / 3\<bar> = real m / real n" and "coprime m n"
    by (rule Rats_abs_nat_div_natE)
  hence "sqrt 2  = 3 * real m / real n" by simp
  hence "\<bar>sqrt 2\<bar>^2 = (3*real m / real n)^2" by simp
  hence "2 = 9*(real m)^2 / (real n)^2" unfolding power_divide by simp
  hence "2 * (real n)^2 = 9*(real m)^2" by (simp add: nonzero_eq_divide_eq `n \<noteq> 0`)
  hence "real (2*n^2) = 9*real (m^2)" by simp
  hence *:"2*n^2 = 9*m^2" by linarith
  hence "even (m^2)" by presburger
  hence "even m" by simp
  then obtain m' where "m=2*m'" by auto
   with * have "2*n^2 = 9*(2*m')^2" by auto
  hence "n^2 = 9*2*m'^2" by auto
  hence "even (n^2)" by presburger
  hence "even n" by simp
  with `even m` and `coprime m n` show False by auto
qed

section \<open> Task 2 \<close>

fun triangle :: "nat \<Rightarrow> nat" where 
  "triangle n = (if n = 0 then 0 else n + triangle(n-1))"

value "triangle 4"

theorem triangle_closed_form: "triangle n = (( n + 1 ) * n div 2)"
proof (induct n)
case 0
  thus ?case by simp
next
  case (Suc k)
  assume "triangle k = (k+1)* k div 2" 
  thus "triangle (Suc k) = (Suc k+1)*Suc k div 2" by simp
qed

fun penta :: "nat \<Rightarrow> nat" where 
  "penta n = (if n = 0 then 1 else 5*n + penta(n-1))"

value "penta 2"

find_theorems "(_ + _)^2"
thm Power.comm_semiring_1_class.power2_sum

find_theorems " _ + _ div _"
thm Fields.division_ring_class.add_divide_eq_if_simps(1)
thm Fields.field_class.add_num_frac

theorem penta_closed_form: "penta n = (5*n^2 + 5*n + 2) div 2"
proof (induct n)
  case 0
  then show ?case by simp
next
  case (Suc k)
  assume IH:"penta k = (5*k^2 + 5*k + 2) div 2 "
 
  have "real (penta (Suc k)) = 5*(Suc k) + penta k" by simp
  also have"... = 5*(k+1) + (5*k^2 + 5*k + 2) div 2" using IH  by simp
  also have "... = 5*k + 5 + (5*k^2 + 5*k + 2 ) div 2" by simp
  also have  "... = ((2*5*k + 2*5) div 2) + ((5*k^2 + 5*k + 2) div 2)" using  Fields.field_class.add_num_frac by auto
  also have " ... = ((2*5*k + 2*5) + ( 5*k^2 + 5*k + 2)) div 2" using Fields.division_ring_class.add_divide_distrib 
    by (smt div_add dvdI even_add even_mult_iff power2_eq_square)
  also have  "... =( (5*k^2 + 10*k + 5) + (5*k + 5) + 2 ) div 2" by simp
  also have  "... = ( 5*(k^2+2*k + 1) + 5*(k+1) + 2) div 2" by simp
  also have  "... = ( 5*(k+1)^2 + 5*(k+1) + 2) div 2" using Power.comm_semiring_1_class.power2_sum 
    by (metis (no_types, lifting) Suc_eq_plus1 add_Suc mult_2 one_add_one one_power2 plus_1_eq_Suc)
  also have   "... = (5 * ((Suc k))\<^sup>2 + 5 * (Suc k) + 2) div 2" by simp
  finally show ?case by simp
qed
section \<open> Task 3 \<close>

fun fib :: "nat \<Rightarrow> nat" where 
  "fib 0 = 0"
| "fib (Suc 0) = 1"
| "fib (Suc (Suc n)) = fib n + fib (Suc n)"
value "fib(10)"

fun luc :: "nat \<Rightarrow> nat" where 
  "luc 0 = 2"
| "luc (Suc 0) = 1"
| "luc (Suc (Suc n)) = luc n + luc (Suc n)"

thm luc.induct
thm fib.induct

thm fib.induct[of "\<lambda>n. luc n \<ge> fib n"]

value "luc(3)"

theorem "luc n \<ge> fib n"
proof (induct rule: fib.induct[of "\<lambda>n. luc n \<ge> fib n"])
case 1
  then show ?case by simp
next
  case 2
then show ?case by simp
next
  case (3 n)
  then show ?case by simp
qed

theorem "luc (Suc n) = fib n + fib (Suc (Suc n))"
proof (induct rule: fib.induct[of "\<lambda>n. luc (Suc n) = fib n + fib (Suc (Suc n))"])
  case 1
then show ?case by simp
next
case 2
  then show ?case by simp
next
  case (3 n)
  then show ?case by simp
qed

datatype "circuit" = 
NOT "circuit"
| AND "circuit" "circuit"
| OR "circuit" "circuit"
| TRUE 
| FALSE
| INPUT "int"

definition "circuit1 == AND (INPUT 1) (INPUT 2)"
definition "circuit2 == OR (NOT circuit1) FALSE"
definition "circuit3 == NOT (NOT circuit2)"
definition "circuit4 == AND circuit3 (INPUT 3)"

fun simulate where 
 "simulate (AND c1 c2) \<rho> = ((simulate c1 \<rho>) \<and>  (simulate c2 \<rho>))"
| "simulate (OR c1 c2) \<rho> = ((simulate c1 \<rho>) \<or>  (simulate c2 \<rho>))"
| "simulate (NOT c) \<rho> = ( \<not> (simulate c \<rho> )) "
| "simulate TRUE \<rho> = True "
| "simulate FALSE \<rho> = False"
| "simulate (INPUT i) \<rho> = (\<rho> i ) " 

value "simulate circuit1 (\<lambda>_. False)"
value "simulate circuit4((\<lambda>_. True)(1 := False))"

fun mirror where 
  "mirror (NOT c) = NOT (mirror c)"
| "mirror (AND c1 c2) = AND (mirror c2) (mirror c1)"
| "mirror (OR c1 c2) = OR (mirror c2) (mirror c1)"
| "mirror TRUE = TRUE"
| "mirror (INPUT i) = INPUT i"
| "mirror FALSE = FALSE"




fun delay :: "circuit \<Rightarrow> nat" where
  "delay (NOT c) = 1 + delay c"
| "delay (AND c1 c2) = 1 + max (delay c1) (delay c2)"
| "delay (OR c1 c2) = 1 + max (delay c1) (delay c2)"
| "delay _ = 0"


theorem "simulate (mirror c) \<rho> = simulate c \<rho>"
proof (induct c)
case (NOT c)
then show ?case by simp
next
case (AND c1 c2)
  then show ?case by auto
next
  case (OR c1 c2)
  then show ?case by auto
next
  case TRUE
  then show ?case by simp
next
  case FALSE
  then show ?case by simp
next
  case (INPUT x)
  then show ?case by simp
qed


fun opt_NOT where 
 "opt_NOT (NOT (NOT c)) = opt_NOT c"
| "opt_NOT (NOT c) = NOT (opt_NOT c)"
| "opt_NOT (AND c1 c2) = AND (opt_NOT c1) (opt_NOT c2)"
| "opt_NOT (OR c1 c2) = OR (opt_NOT c1) (opt_NOT c2)"
| "opt_NOT c = c"

value "circuit4"
value "opt_NOT circuit4"

thm opt_NOT.induct


theorem "simulate (opt_NOT c) \<rho> = simulate c \<rho>" 
proof (induct rule: opt_NOT.induct, auto)
qed

fun equal_delay where
"equal_delay (AND c1 c2) = (if delay(c1) = delay(c2) then True else False)"
| "equal_delay (OR c1 c2) = (if delay(c1) = delay(c2) then True else False)"
| "equal_delay (NOT c1) = False"
| "equal_delay (c) = False"


fun is_balanced :: "circuit \<Rightarrow> bool" where
 "is_balanced (NOT c1) = is_balanced(c1)"
|"is_balanced (AND c1 c2) = ((equal_delay(AND c1 c2)) \<and> ((is_balanced(c1)) \<and> (is_balanced(c2))))"
| "is_balanced (OR c1 c2) = ((equal_delay(OR c1 c2)) \<and> ((is_balanced(c1)) \<and> (is_balanced(c2))))"
| "is_balanced (c) = True"


definition "new_circuit = AND (NOT TRUE) (TRUE)"
definition "true_circuit = AND (NOT TRUE) (OR TRUE (INPUT 1))"

definition "branch1 = OR ((INPUT 3))(NOT (INPUT 2))"
definition "branch2 = (AND (INPUT 1) (INPUT 1))" 
definition "circuit6 = AND (branch1) ( branch2)"
definition "circuit5 = NOT circuit6"




value "is_balanced(new_circuit)"
value "is_balanced(true_circuit)"
value "is_balanced(circuit5)"
value "is_balanced(NOT TRUE)"
value "is_balanced(AND (INPUT 3) (INPUT 3))"
value "is_balanced(NOT (INPUT 2))"
value "is_balanced(branch1)"
value "is_balanced(branch2)"
value "is_balanced(circuit6)"

function balance :: "circuit \<Rightarrow> circuit" where 
"balance (TRUE) = TRUE"| "balance (FALSE) = FALSE"| "balance (INPUT i) = INPUT i"
| "balance (NOT (x)) = (if (is_balanced(NOT x)) then NOT x else NOT (balance(x)) )   "
| "balance (AND c1 c2) = (
if is_balanced(AND c1 c2) 
  then AND c1 c2
else 
  if delay(c1) > delay(c2) 
    then balance( AND (c1) (AND c2 c2) ) 
  else 
    if delay(c2) > delay(c1) 
      then balance( AND (AND c1 c1) (c2))
    else 
      AND (balance(c1)) (balance(c2)) 
)"
| "balance (OR c1 c2) = (
if is_balanced(OR c1 c2) 
  then OR c1 c2
else 
  if delay(c1) > delay(c2) 
    then balance( OR (c1) (AND c2 c2) ) 
  else 
    if delay(c2) > delay(c1) 
      then balance( OR (AND c1 c1) (c2))
    else 
      OR (balance(c1)) (balance(c2)) 
)"
  by pat_completeness auto
termination sorry

definition "output = NOT (AND (AND (OR (AND (INPUT 3) (INPUT 3)) (NOT (INPUT 2))) (OR (AND (INPUT 3) (INPUT 3)) (NOT (INPUT 2))))
       (NOT (NOT (AND (INPUT 1) (INPUT 1))))   )"
value "balance(output)"
value "balance(circuit6)"
value "balance(circuit5)"

thm balance.induct


value "balance (circuit5)"
value "output"
value "is_balanced(balance(circuit5))"
theorem "simulate (balance c) \<rho> = simulate c \<rho>" 
proof (induct rule: balance.induct)
  case 1
  then show ?case 
    by simp
next
  case 2
  then show ?case by simp
next
  case (3 i)
  then show ?case by simp
next
  case (4 x)
  then show ?case by simp
next
  case (5 c1 c2)
  then show ?case by simp
next
  case (6 c1 c2)
  then show ?case by simp
qed


theorem "is_balanced(balance(c)) = True"
proof(induct c)
case (NOT c)
  then show ?case by simp
next
  case (AND c1 c2)
  then show ?case sorry
next
  case (OR c1 c2)
  then show ?case sorry
next
  case TRUE
  then show ?case by simp
next
  case FALSE
then show ?case by simp
next
  case (INPUT x)
then show ?case by simp
qed

section \<open> Task V \<close>
datatype "circuit1" = 
NOT "circuit1"
| AND "circuit1" "circuit1"
| OR "circuit1" "circuit1"
| TRUE 
| FALSE
| INPUT "int"
| NAND "circuit1" "circuit1"


fun simulate1 where 
 "simulate1 (AND c1 c2) \<rho> = ((simulate1 c1 \<rho>) \<and>  (simulate1 c2 \<rho>))"
| "simulate1 (OR c1 c2) \<rho> = ((simulate1 c1 \<rho>) \<or>  (simulate1 c2 \<rho>))"
| "simulate1 (NOT c) \<rho> = ( \<not> (simulate1 c \<rho> )) "
| "simulate1 TRUE \<rho> = True "
| "simulate1 FALSE \<rho> = False"
| "simulate1 (INPUT i) \<rho> = (\<rho> i ) " 
| "simulate1 (NAND c1 c2) \<rho> =( \<not> ((simulate1 c1 \<rho>) \<and>  (simulate1 c2 \<rho>)) )"

fun transform_to_NAND where 
"transform_to_NAND (TRUE) = TRUE"
|
"transform_to_NAND (FALSE) = NAND (TRUE) (TRUE)"
|
"transform_to_NAND (INPUT i) = INPUT i"
| "transform_to_NAND (NAND c1 c2) = NAND (transform_to_NAND(c1)) (transform_to_NAND(c2))"
| "transform_to_NAND (AND c1 c2) = NAND ( NAND (transform_to_NAND(c1)) (transform_to_NAND(c2))) ( NAND (transform_to_NAND(c1)) (transform_to_NAND(c2)))"
| "transform_to_NAND (OR c1 c2) =   NAND ( NAND (transform_to_NAND(c1)) (transform_to_NAND(c1)) ) (NAND (transform_to_NAND(c2))  (transform_to_NAND(c2)))"
| "transform_to_NAND (NOT c) = NAND (transform_to_NAND(c)) (transform_to_NAND(c))"

value "simulate1(NAND (NOT TRUE) (NOT TRUE)) \<rho>"

fun Only_Contains :: "circuit1 \<Rightarrow> bool" where
"Only_Contains TRUE = True"
|"Only_Contains FALSE  = False"
| "Only_Contains (INPUT i)  = True"
| "Only_Contains (NOT c) = False"
| "Only_Contains (AND c1 c2)  = False"
| "Only_Contains (OR c1 c2) = False"
| "Only_Contains (NAND (c1) (c2))  = ((Only_Contains (c1)) \<and>  (Only_Contains (c2)))"

thm transform_to_NAND.induct
theorem  "simulate1 (transform_to_NAND c) \<rho> = simulate1 c \<rho>"
proof (induct rule: transform_to_NAND.induct, auto)
qed
theorem "Only_Contains(transform_to_NAND(c)) = True"
proof(induct c)
case (NOT c)
then show ?case by simp
next
case (AND c1 c2)
  then show ?case by simp
next
  case (OR c1 c2)
  then show ?case by simp
next
  case TRUE
  then show ?case by simp
next
  case FALSE
  then show ?case by simp
next
  case (INPUT x)
  then show ?case by simp
next
  case (NAND c1 c2)
  then show ?case by simp
qed
fun delay1 :: "circuit1 \<Rightarrow> nat" where
  "delay1 (NOT c) = 1 + delay1 c"
| "delay1 (AND c1 c2) = 1 + max (delay1 c1) (delay1 c2)"
| "delay1 (OR c1 c2) = 1 + max (delay1 c1) (delay1 c2)"
| "delay1 (NAND c1 c2) = 1 + max (delay1 c1) (delay1 c2)"
| "delay1 _ = 0"

theorem "delay1(transform_to_NAND(c)) \<le> 2*delay1(c) + 1 "
proof(induct c)
  case (NOT c)
then show ?case 
  by simp
next
  case (AND c1 c2)
  then show ?case 
    by auto
next
  case (OR c1 c2)
  then show ?case 
    by auto
next
  case TRUE
  then show ?case 
    by simp
next
case FALSE
then show ?case 
  by simp
next
case (INPUT x)
  then show ?case 
    by simp
next
  case (NAND c1 c2)
  then show ?case 
    by auto
qed
end
