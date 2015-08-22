
 ![R. Mutt](rmutt.gif)

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**How to Write rmutt Grammars**</font>

Grammars in rmutt consist primarily of rules. Rules are named and specify which choices are allowable at a given point in the grammar. To do this, they can either include literal text which rmutt will output, or they can refer to other rules. The simplest rule simply associates a name with some literal text:

> <font face="Courier New, Courier, mono">day: "Thursday";</font>

This tells rmutt to produce the string "Thursday" every time it encounters the "day" rule. So for instance if rmutt encountered the rule:

> <font face="Courier New, Courier, mono">announcement: "I'm leaving on " day;</font>

it would produce

> <font face="Courier New, Courier, mono">I'm leaving on Thursday</font>

In the example, the literal "I'm leaving on " is followed by the term "day", which tells rmutt to look up the rule named "day" to determine what to output next.

A rule can contain more than one allowable choice. Choices are separated by commas. So for instance if we change our first rule to:

> <font face="Courier New, Courier, mono">day: "Thursday", "Friday" , "Saturday";</font>

then the "announcement" rule could also produce

> <font face="Courier New, Courier, mono">I'm leaving on Friday</font>

or

> <font face="Courier New, Courier, mono">I'm leaving on Saturday</font>

rmutt chooses randomly, so there's no way to predict which choice it will make for any given rule.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Anonymous Rules**</font>

Sometimes it's inconvenient to define a new rule every time you want rmutt to make a choice. To make this more convenient, rmutt allows for anonymous rules which may be used anywhere in a rule. They're set off by parentheses. For example, we could rewrite our announcement rule as follows:

> <font face="Courier New, Courier, mono">announcement: "I'm " <font color="#FF0000">("leaving" , "staying")</font> " tomorrow";</font>

rmutt will either produce

> <font face="Courier New, Courier, mono">I'm leaving tomorrow</font>

or

> <font face="Courier New, Courier, mono">I'm staying tomorrow</font>

In case you're wondering, this has exactly the same behavior as the following two rules:

> <font face="Courier New, Courier, mono">announcement: "I'm " sol " tomorrow";
>  sol: "staying", "leaving";</font><input type="hidden" name="grammar" value="announcement: &quot;I'm &quot; sol &quot; tomorrow&quot;;
> sol: &quot;staying&quot;, &quot;leaving&quot;;">

Anonymous rules can be nested arbitrarily deeply, as in this example:

> <font face="Courier New, Courier, mono">brag: "I have a " (("cool" , "fast") " car", ("great", "winning") " personality") "!";</font>

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Repetition**</font>

rmutt allows you to control how many times to repeat each part of a rule by specifying a minimum and maximum number of allowable repetitions. This is done with the "repetition qualifier" in the form <font face="Courier New, Courier, mono">{</font>_min_<font face="Courier New, Courier, mono">,</font>_max_<font face="Courier New, Courier, mono">}</font> to specify a minumum and maximum number of repetitions or simply <font face="Courier New, Courier, mono">{</font>_num_<font face="Courier New, Courier, mono">}</font> to specify an exact number of repetitions. For example, the following rule:

> <font face="Courier New, Courier, mono">howfar: "very, "<font color="#FF0000">{3,4}</font> "far away";</font>

might produce:

> <font face="Courier New, Courier, mono">very, very, very, far away</font>

The repetition notation can be applied to non-literals as well. For instance, it could be applied to the invocation of another rule:

> <font face="Courier New, Courier, mono">howfar: <font color="#FF0000">emph</font>{3,4} "far away";
>  <font color="#FF0000">emph: "very, ", "really, ", "extremely, "</font>;</font><input type="hidden" name="grammar" value="howfar: emph{3,4} &quot;far away&quot;;
> emph: &quot;very, &quot;, &quot;really, &quot;, &quot;extremely, &quot;;  ">

might produce:

> <font face="Courier New, Courier, mono">really, really, extremely, really, far away</font>

Just as parentheses can be used for anonymous rules, they can also be used to group terms so that the repetition qualifier can be applied to the group. For example we can rewrite our following example like so:

> <font face="Courier New, Courier, mono">howfar: <font color="#FF0000">(emph ", ")</font>{3,4} "far away";
>  emph: <font color="#FF0000">"very"</font>, <font color="#FF0000">"really"</font> , <font color="#FF0000">"extremely"</font>;</font><input type="hidden" name="grammar" value="howfar: (emph &quot;, &quot;){3,4} &quot;far away&quot;;
> emph: &quot;very&quot;, &quot;really&quot;, &quot;extremely&quot;;">

which saves us having to include the comma in each choice for "emph", since we've grouped it with the invocation of "emph" in the first rule.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+1">**Shorthand repetition qualifiers** <font color="#AAAAAA">(v1.3+)</font></font>

There are three shorthand repeition qualifiers that you can use in place of the curly-brace notation. They are as follows:

<font face="Courier New, Courier, mono">?</font>: <font face="Courier New, Courier, mono">{0,1}</font>  
<font face="Courier New, Courier, mono">*</font>: <font face="Courier New, Courier, mono">{0,5}</font>  
<font face="Courier New, Courier, mono">+</font>: <font face="Courier New, Courier, mono">{1,5}</font>  

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Embedded Definitions**</font>

In rmutt, a rule can change the definition of another rule or define a new rule. This makes certain kinds of context-dependent behavior easier to implement. For instance, suppose you had the following fragmentary English grammar:

> <font face="Courier New, Courier, mono">vp: iv " " adv " " pp;
>  iv: "ate", "yelled", "waited";
>  pp: prep " " obj;
>  prep: "to", "at", "for", "on";
>  obj: "you", "me";
>  adv: "patiently", "impatiently";</font><input type="hidden" name="grammar" value="vp: iv &quot; &quot; adv &quot; &quot; pp;
> iv: &quot;ate&quot;, &quot;yelled&quot;, &quot;waited&quot;;
> pp: prep &quot; &quot; obj;
> prep: &quot;to&quot;, &quot;at&quot;, &quot;for&quot;, &quot;on&quot;;
> obj: &quot;you&quot;, &quot;me&quot;;
> adv: &quot;patiently&quot;, &quot;impatiently&quot;;">

Here we've specified that a verb phrase ("vp") consists of an intransitive verb ("iv") followed by an adverb ("adv") followed by a prepositional phrase ("pp"). As this grammar stands, however, it can produce non-idiomatic combinations of verbs and prepositions, such as "ate patiently at you" or "waited impatiently to me". To fix this, we need the "prep" rule to change based on which verb was selected. This can be done by embedding the definitions of "iv" and "prep" in choices together:

> <font face="Courier New, Courier, mono"><font color="red">meta-vp:
>  (iv: "ate") (prep: "with") vp,
>  (iv: "yelled") (prep: "at") vp,
>  (iv: "waited") (prep: "for","on","with") vp;</font>
>  vp: iv " " adv " " pp;
>  pp: prep " " obj;
>  obj: "you", "me";
>  adv: "patiently", "impatiently";</font><input type="hidden" name="grammar" value="meta-vp:
>  (iv: &quot;ate&quot;) (prep: &quot;with&quot;) vp,
>  (iv: &quot;yelled&quot;) (prep: &quot;at&quot;) vp,
>  (iv: &quot;waited&quot;) (prep: &quot;for&quot;,&quot;on&quot;,&quot;with&quot;) vp;
> vp: iv &quot; &quot; adv &quot; &quot; pp;
> pp: prep &quot; &quot; obj;
> obj: &quot;you&quot;, &quot;me&quot;;
> adv: &quot;patiently&quot;, &quot;impatiently&quot;;">

This new grammar can produce the following strings:

> <font face="Courier New, Courier, mono">ate patiently with me
>  waited impatiently for you
>  yelled patiently at you</font>

but not:

> <font face="Courier New, Courier, mono">waited patiently at me
>  ate impatiently at you
>  yelled patiently on me</font>

Embedded definitions are surrounded by parentheses, and are otherwise the same as top-level definitions. They may occur anywhere in a choice for a rule, since they produce no output. There's no limit to the number of embedded rules that a rule can contain, or to the complexity of embedded rules.

The scope of rules defined by embedded definitions is lexical by default. In other words, as rmutt proceeds from left to right producing strings satisfying each grammatical unit in the sequence of units associated with a choice, any embedded rule definitions it encounters will be in effect from that time forward, but only in the subtree in which the embedded definition occurs.

The scope of an embedded definition can be controlled with the scope qualifier "$". If you place this qualifier in front of the label of an embedded rule, it will modify any existing binding for that label, rather than creating a new local binding. See the [Turing machine example](https://web.archive.org/web/20120208110629/http://www.schneertz.com/rmutt/turing.rm.txt) for an example of this syntax.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Variables**</font>

Variables are another way to implement context-dependent behavior. A variable is like an embedded rule whose choices are only made once. Every time the variable is invoked, it will produce the same string. Variable assignments are indicated with an equals sign (=). For instance, the following grammar:

> <font face="Courier New, Courier, mono">s: <font color="#FF0000">(character = name, position)</font> character " said, 'I am " character ", so nice to meet you.'";
>  name: title " " firstName " " lastName;
>  title: "Dr.", "Mr.", "Mrs.", "Ms";
>  firstName: "Nancy", "Reginald", "Edna", "Archibald";
>  lastName: "McPhee", "Eaton-Hogg", "Worthingham";
>  position: "the butler", "the chauffeur";</font><input type="hidden" name="grammar" value="s: (character = name, position) character &quot; said, 'I am &quot; character &quot;, so nice to meet you.'&quot;;
> name: title &quot; &quot; firstName &quot; &quot; lastName;
> title: &quot;Dr.&quot;, &quot;Mr.&quot;, &quot;Mrs.&quot;, &quot;Ms&quot;;
> firstName: &quot;Nancy&quot;, &quot;Reginald&quot;, &quot;Edna&quot;, &quot;Archibald&quot;;
> lastName: &quot;McPhee&quot;, &quot;Eaton-Hogg&quot;, &quot;Worthingham&quot;;
> position: &quot;the butler&quot;, &quot;the chauffeur&quot;;">

can produce the following strings:

> <font face="Courier New, Courier, mono">Ms Reginald Worthingham said, 'I am Ms Reginald Worthingham, so nice to meet you.'
>  Mr. Edna Worthingham said, 'I am Mr. Edna Worthingham, so nice to meet you.'
>  the butler said, 'I am the butler, so nice to meet you.'</font> <font face="Courier New, Courier, mono">Mrs. Nancy McPhee said, 'I am Mrs. Nancy McPhee, so nice to meet you.'</font>

Like embedded definitions, variable assignments are surrounded by square brackets, and are otherwise the same as top-level definitions. They may occur anywhere in a choice for a rule, since they produce no output.

The scope of variable assignments is lexical, just like embedded definitions. In fact, a variable assignment is just a degenerate form of rule definition which only allows one choice per rule.

As with embedded definitions, the scope of the assignment can be controlled with the "$" scope qualifier.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Transformations: Mappings**</font>

In addition to controlling what text is produced by a complex of rules, you can also apply transformations to the text produced by rules and parts of rules. Transformations are indicated with a right angle bracket which points from the rule part to the transformation which is to be applied to its output.

The simplest form of transformation is a mapping, which produces a substitute value if the value to be transformed exactly matches a given string. For instance the mapping:

> <font face="Courier New, Courier, mono">scaryAnimal: animal <font color="#FF0000">> "fish" % "shark"</font>;
>  animal: "fish", "cat";</font><input type="hidden" name="grammar" value="scaryAnimal: animal > &quot;fish&quot; % &quot;shark&quot;;
> animal: &quot;fish&quot;, &quot;cat&quot;; ">

produces either "cat" or "shark". Mappings are indicated with a percent sign (%). Mappings can be grouped either by defining them as named rules or enclosing them in parentheses. For instance, the grammar

> <font face="Courier New, Courier, mono">scaryAnimal: animal > <font color="#FF0000">("fish" % "shark" "cat" % "lion")</font>;
>  animal: "fish", "cat";</font><input type="hidden" name="grammar" value="scaryAnimal: animal > (&quot;fish&quot; % &quot;shark&quot; &quot;cat&quot; % &quot;lion&quot;);
> animal: &quot;fish&quot;, &quot;cat&quot;;">

produces either "shark" or "lion". We could also name the transformation by defining it as a rule:

> <font face="Courier New, Courier, mono">scaryAnimal: animal > <font color="#FF0000">makeScary</font>;
>  animal: "fish", "cat";
>  <font color="#FF0000">makeScary: "fish" %"shark" "cat" % "lion"</font>;</font><input type="hidden" name="grammar" value="scaryAnimal: animal > makeScary;
> animal: &quot;fish&quot;, &quot;cat&quot;;
> makeScary: &quot;fish&quot; % &quot;shark&quot; &quot;cat&quot; % &quot;lion&quot;;">

Mappings are useful for setting up associations between choices. For instance the following example maps basketball team names to the cities they're from:

> <font face="Courier New, Courier, mono">s: (myteam = team) "The " myteam " are from " myteam > team2city;
>  team: "Sparks", "Comets";
>  team2city: "Sparks" % "L.A." "Comets" % "Houston";</font><input type="hidden" name="grammar" value="s: (myteam = team) &quot;The &quot; myteam &quot; are from &quot; myteam > team2city;
> team: &quot;Sparks&quot;, &quot;Comets&quot;;
> team2city: &quot;Sparks&quot; % &quot;L.A.&quot; &quot;Comets&quot; % &quot;Houston&quot;;">

which can produce the following strings:

> <font face="Courier New, Courier, mono">the Sparks are from L.A.
>  the Comets are from Houston</font>

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Transformations: Regular Expressions**</font>

For the die-hard UNIX hacker inside each of us, rmutt allows regular expression substitutions to be used as transformations. A discussion of regular expressions is beyond the scope of this document. There are many useful resources on the web to help learn them. A good starting place is [A Tao of Regular Expressions](https://web.archive.org/web/20120208110629/http://sitescooper.org/tao_regexps.html). One warning: the syntax of regular expressions differs significantly from application to application. rmutt uses POSIX extended regular expressions. If you don't know what that means, beware!

Regular expression substitutions are written in the form "<font face="Courier New, Courier, mono">/</font>_reg. exp._<font face="Courier New, Courier, mono">/</font>_replacement_<font face="Courier New, Courier, mono">/</font>". Here's a simple example of regular expression substitution:

> <font face="Courier New, Courier, mono">s: "i like to eat apples and bananas" > <font color="#FF0000">/[aeiou]/oo/</font>;</font><input type="hidden" name="grammar" value="s: &quot;i like to eat apples and 
>     bananas&quot; > /[aeiou]/oo/;">

this produces:

> <font face="Courier New, Courier, mono">oo lookoo too oooot oopploos oond boonoonoos</font>

Like mapping transformations, regular expression transformations can be defined as rules or enclosed in parentheses.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Transformation Chaining**</font>

Any transformation can be applied to the result of a previous transformation by transformation chaining. This is indicated simply by using a transformation as the left-hand-side of another transformation, like so:

> <font face="Courier New, Courier, mono">thing: "cat" > /t/b/ > "cab" % "taxi";</font>

The grammar above will produce "taxi". Transformation chains can be arbitrarily long. For instance, the following grammar

> <font face="Courier New, Courier, mono">thing: name > deleteVowels > slangify > deleteVowels;
>  deleteVowels: /[aeiou]//;
>  slangify: "chck" % "chiggidy" "snp" % "snippidy";
>  name: "check", "chuck", "snap", "snipe";</font><input type="hidden" name="grammar" value="thing: name > deleteVowels > slangify > deleteVowels;
> deleteVowels: /[aeiou]//;
> slangify: &quot;chck&quot; % &quot;chiggidy&quot; &quot;snp&quot; % &quot;snippidy&quot;;
> name: &quot;check&quot;, &quot;chuck&quot;, &quot;snap&quot;, &quot;snipe&quot;;">

will produce either "chggdy" or "snppdy".

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Packages**</font>

When a grammar has many rules and variables in it, it's difficult to keep track of their names and make sure that each name is unique. This is especially a problem when combining two grammars that may have been developed independently. To solve this problem, rmutt uses "packages", requiring only that each name be unique within a package. To switch to a particular package, use the "package" statement:

> <font face="Courier New, Courier, mono" color="#FF0000">package greeting;</font><font face="Courier New, Courier, mono">
>  
> s: "hello there " o;
>  o: "beautiful", "Mr. Smarty Pants";</font>

This means that "s" and "o" are to be understood as names within the package called "greeting". Outside of the package, each rule must be referred to by its "fully qualified" name, which consists of the package name, followed by a period, followed by the unqualified name (e.g. "greeting.s").

Here's how we can use two packages in the same grammar:

> <font face="Courier New, Courier, mono">package lesson;
>  
> sentence: o " starts with the letter 'O', " <font color="#FF0000">greeting.o</font>;
>  o: "oatmeal", "ogre";
>  
> package greeting;
>  
> s: "hello there " o;
>  o: "beautiful", "Mr. Smarty Pants";</font><input type="hidden" name="grammar" value="package lesson;
>  
> sentence: o &quot; starts with the letter 'O', &quot; greeting.o;
> o: &quot;oatmeal&quot;, &quot;ogre&quot;;
>  
> package greeting;
>  
> s: &quot;hello there &quot; o;
> o: &quot;beautiful&quot;, &quot;Mr. Smarty Pants&quot;;">

Notice that in the first rule we're using the fully-qualified name "greeting.o" to indicate that we want to use the definition of "o" from the "greeting" package and not from the "lesson" package. This grammar might generate the following strings:

> <font face="Courier New, Courier, mono">ogre starts with the letter 'O', beautiful
>  ogre starts with the letter 'O', Mr. Smarty Pants</font>

Before the first package statement in a grammar, rmutt considers names to be in the default package, which is a package with no name. The disadvantage of using this package is that there is no fully-qualified name for any rule or variable from the default package, since all names in rmutt, including package names, must be at least one character long. If you use a name in a package, rmutt will first search the current package for that name, and if it can't find it there will then search the default package.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Includes <font color="#AAAAAA">(v1.6+)</font>**</font>

If you're familiar with C or C++, you'll recognize rmutt's syntax for merging two or more grammar files. Suppose you've written a grammar that generates random email addresses, which you've stored in a file called "<font face="Courier New, Courier, mono">email.rm</font>", and you'd like to reuse it in another grammar. The following example shows how to do this.

> <font face="Courier New, Courier, mono"><font color="red">#include "email.rm"</font>
>  
> sentence: "my email address is " email_addr "\n";</font>

In this example, the "<font face="Courier New, Courier, mono">email_addr</font>" rule from <font face="Courier New, Courier, mono">email.rm</font> is used. When you use an include, take care that the included file does not define rules with the same names as rules you have defined in the including grammar, or whichever definition occurs last will override the previous definition. You can avoid these problems by using packages.

Includes can occur anywhere in a grammar.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Probability multipliers <font color="#AAAAAA">(v1.2+)</font>**</font>

A choice can be followed by an optional probability multiplier, which increases the probability that it will be selected, relative to other choices in the same rule. A probability multiplier consists of an integer at the end of a choice. Larger integers denote higher selection probabilities. For instance

> <font face="Courier New, Courier, mono">number: digit{16};
>  digit: "0" <font color="#FF0000">12</font>, "1";</font><input type="hidden" name="grammar" value="number: digit{16};
> digit: &quot;0&quot; 12, &quot;1&quot;;">

will produce a string of 16 zeros and ones, which is likely to consist mostly of zeroes. Probability multipliers are a shorthand for repeatedly adding a choice to the rule. The above grammar is identical to the following one:

> <font face="Courier New, Courier, mono">number: digit{16};
>  digit: "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "1";</font><input type="hidden" name="grammar" value="number: digit{16};
> digit: &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;0&quot;, &quot;1&quot;;">

Rmutt does not support non-integer weights on choices, because this would make it impossible to enumerate all possible outcomes for a given grammar.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Running rmutt**</font>

rmutt is a command-line program which accepts a grammar as an input. If you have a file with an rmutt grammar on it, you can mention it on the command line like this:

> <font face="Courier New, Courier, mono">rmutt myfile.rm</font>

If you want to save the output to a file you can simply redirect it:

> <font face="Courier New, Courier, mono">rmutt myfile.rm > myoutputfile</font>

If you have a program which generates an rmutt grammar, you can pipe it through rmutt like this:

> <font face="Courier New, Courier, mono">myprogram | rmutt</font>

Note: rmutt does not require that the names of grammar files end with ".rm" or any other specific extension.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+1">**Command-line options**</font>

*   <font face="Courier New, Courier, mono">-s [stack depth]</font>: Specify the maximum depth to which rmutt will expand the grammar. This is usually used to prevent recursive grammars from crashing rmutt with stack overflows. Beyond the maximum stack depth, a rule will expand to an empty, zero-length string.
*   <font face="Courier New, Courier, mono">-r [random seed]</font>: Specify a seed for the random number generator. Two runs against the same grammar with the same seed will generate identical output. If no seed is specified, a seed is generated using the current system clock.
*   <font face="Courier New, Courier, mono">-i [iteration]</font>: A given rmutt grammar can generate n possible strings, where n is finite or infnite depending on whether or not the grammar is recursive. Specifying an iteration will generate the nth possible string. If the iteration specified (call it i) is greater than n, rmutt will generate the (i mod n)th iteration. Enumerating all possible strings of a grammar is usually only useful for very simple grammars; most grammars can produce more strings than can be enumerated with a C int.
*   <font face="Courier New, Courier, mono">-e [label]</font>: To produce a string, rmutt must start with one of the rules in the grammar. Use this option to specify which one. By default, rmutt expands the first rule it finds in the grammar.
*   <font face="Courier New, Courier, mono">-d</font>: Use dynamic variable scope. Deprecated; use the "$" qualifier instead.
*   <font face="Courier New, Courier, mono">-v</font>: Print version and other information and exit.

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Other Important Things**</font>

* by default, rmutt invokes the first rule in its input. Think of this as the "entry point" for your grammar.

* All top-level rules and package statements must end in a semicolon (;).

* Line breaks are not significant; you may use them whenever is convenient.

* rmutt cannot detect certain kinds of errors; in particular, if your grammar is endlessly recursive, like so:

> <font face="Courier New, Courier, mono">deadly: embrace;
>  embrace: deadly;</font>

rmutt will run out of memory and silently fail as it tries to make an infinitely-long string. To mitigate this you can use the <font face="Courier New, Courier, mono">-s</font> command line option, which sets a limit on the recursion depth. Past the limit, rules will simply fail to expand. For instance if the file "<font face="Courier New, Courier, mono">foo.rm</font>" contained the following grammar:

> <font face="Courier New, Courier, mono">foo: "yes" bar;
>  bar: foo;</font>

and you ran the following command:

> <font face="Courier New, Courier, mono">rmutt -s 20 foo.rm</font>

you'd get this output:

> <font face="Courier New, Courier, mono">yesyesyesyesyesyesyesyesyesyes</font>

* Repetition can be combined with transformations, but the repetition qualifier must come last, like this:

> <font face="Courier New, Courier, mono">aRule: "clam" > /m/mp/ {2,10};</font>

not

> <font face="Courier New, Courier, mono">aRule: "clam" {2,10} > /m/mp/;</font>

if you want the repetition to be applied before the transformation, you need to enclose the term _and_ repetition qualifier in parentheses:

> <font face="Courier New, Courier, mono">aRule: ("clam"{2,10}) > /mc/m, c/ "!";</font>

* Comments can be included in rmutt grammars. If two slashes in a row ("<font face="Courier New, Courier, mono">//</font>") occur anywhere on a line, the rest of the line is treated as a comment and ignored.

* To include special chacters in literals, use the following notations:

Double quotes: <font face="Courier New, Courier, mono">\"</font>  
Newline: <font face="Courier New, Courier, mono">\n</font>  
Tab: <font face="Courier New, Courier, mono">\t</font>  
Backslash: <font face="Courier New, Courier, mono">\\</font>  

<font face="Verdana, Arial, Helvetica, sans-serif" size="+2">**Curiosities**</font>

*   rmutt is [Turing-complete](http://en.wikipedia.org/wiki/Turing-complete). turing.rm is an implementation of a Turing machine in rmutt 2.3.

