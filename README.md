Sanzang (三藏)
==============

Contents
--------

* Introduction
* Concepts
* Installation
* Components
* Basic Usage
* Advanced Usage
* Responsible Use

Introduction
------------

Sanzang is a compact, cross-platform machine translation system. This program
was developed specifically to fill the need for a competent application for
aiding translators of the Chinese Buddhist canon into other languages. However,
the translation method it uses is general enough that it may extend to other
translation domains as well, especially those in which Chinese is the source
language. Sanzang (三藏) is a literal translation of the Sanskrit word
"Tripitaka," a general term for the Buddhist canon. Sanzang is alternately
a translation of "trepitaka," the title for someone who is a master of such
teachings.

Sanzang is implemented as a small set of programs written in the Ruby
programming language. This system is free software (“free as in freedom”), and
it is licensed under the GNU General Public License, version 3. This ensures
that anyone can use the program for any purpose, and that any extensions to
Sanzang will remain freely available to others.

Background
----------

The most significant difference between Sanzang and other machine translation
systems is that it does not attempt to interpret grammar in any way. Instead,
it relies on direct translation of names, terms, and phrases based on a large
translation table. The Sanzang translator simply applies this translation table
at runtime, and does not attempt to interpret grammar or syntax in any way
whatsoever. The end result is that the accuracy of the translation is highly
dependent on the accuracy of the translation table.

The strength of the Sanzang method is that it is extremely simple and easy to
work with, and eliminates virtually all complexity in the translation process.
This system will never produce incorrect syntax because it does not interpret
syntax in the first place. This method is also efficient and yields predictable
results that can be made immediately available to the user for verification. To
facilitate this task, all translation listings are collated line-by-line with
the original source text.

Concepts
--------

Sanzang provides mainly a simple translation engine. For any actual
translation work, Sanzang requires a translation table in which all
translation rules are defined. This translation table is stored in a simple
text file. Each line is a record containing a source term and its equivalent
meanings in other languages. Each line starts with "~|", has records delimited
by "|", and ends with "|~". In a table, the first column represents the source
language, while the subsequent columns represent destination languages. In
this example, we want to create a table capable of rendering the following
title into English:

    金剛般若波羅蜜經

We start by creating a new text file, named TABLE.txt or something similar. In
this text file, we may add the following rules:

    ~|波羅蜜| pāramitā|~
    ~|金剛| diamond|~
    ~|般若| prajñā|~
    ~|經| sūtra|~

Did you notice that we included spaces prior to the translations of these
terms? This is because Chinese does not typically include spaces between
words, so we need to insert our own leading spaces as part of the rules we are
defining. After we have written this table file, we can run the Sanzang
translator with our table. When it reads the Chinese title as the input text,
it then produces the following translation listing:

    1.1 金剛般若波羅蜜經
    1.2  diamond prajñā pāramitā sūtra

The program first sorted our terms by the length of the source column, and
then applied each of these rules in sequence. It then collated the output and
created a translation listing. In the left margin, we can see numbers denoting
the line number of the source text, along with the column number of the
translation table.

As a final example, below is a snippet from an ancient meditation text, which
was also processed by the Sanzang translator in the same manner:

    105.1 阿難白佛言。
    105.2  ānán bái-fó-yán ¶
    105.3  ānanda addressed-the-buddha-saying ¶

    106.1 唯然世尊。
    106.2  wéi-rán shìzūn ¶
    106.3  just-so bhagavān ¶

    107.1 願樂欲聞。
    107.2  yuànlè-yù-wén ¶
    107.3  joyfully-wish-to-hear ¶

Here we can see a three-column translation table at work. The first column has
the traditional Chinese source text, the second column contains the Pinyin
transliteration, and the third column contains English. In this example we can
see that well-defined translation rules lead to a clear translation listing,
at which the meaning of the original text is readily understandable in
English. If we wished to add additional columns for simplified Chinese,
Vietnamese, Japanese, Spanish, French, German, Russian, or any other languages,
then these could all be handled similarly without any technical difficulties.

Comprehensive translation tables could be quite large, containing tens of
thousands of entries. However, the work of building such a table is not so
significant compared to the long-term benefits which may be gained from such
tables. In addition, rules in these translation tables may be translated into
other languages as well. There is a potential here to assist readers all over
the world with understanding otherwise difficult works.

Considering the examples above, we can see that knowledge of the source
language and expertise in the relevant literary field is often still necessary.
Here again we can see that this translation system does not position itself as
a “silver bullet” for creating finished translations, but is rather a practical
set of utilities for the purpose of assisting human readers and translators.

Installation
------------

### Requirements

The Sanzang system can be installed either as a Ruby gem, or manually from
an archive file. The only prerequisite to using Sanzang is:

* Ruby 1.9 or later

The "parallel" gem is required by Sanzang, but is installed automatically when
installing Sanzang using the standard method. Using the "parallel" gem, Sanzang
can support multiprocessing in batch mode (if the platform supports it).
Currently this method of multiprocessing will work automatically on Ruby ports
that implement the Process#fork system call.

In addition to the actual runtime requirements, it may also be very useful to
have a text editor that is aware of Unicode and other encodings, and able to
display multilingual texts. One such application that is known to work well
for this task is the _gedit_ text editor, which is free software and also
available on a variety of platforms.

### Installation

To install Sanzang, the following command should suffice.

    # gem install sanzang

If you have installed Ruby 1.9 but cannot run the "gem" command, then you may
need to set up your PATH environment variable first, so you can run _ruby_ and
_gem_ from the command line.

Components
----------

The programs in Sanzang are designed in a traditional Unix style in which
programs are executed in a terminal, and program settings are specified
through command line options and parameters. This allows Sanzang programs
to be easily scripted and automated.

### sanzang-reflow

The program sanzang-reflow can reformat Chinese, Japanese, or Korean text, in
which terms are often split between lines. This formatter "reflows" the text
instead based on its punctuation and horizontal spacing, separating the source
text into lines that are much safer for translation using the sanzang-translate
program.

    Usage: sanzang-reflow [options]

    Options:
        -h, --help                       show this help message and exit
        -E, --encoding=ENC               set data encoding to ENC
        -L, --list-encodings             list possible encodings
        -i, --infile=FILE                read input text from FILE
        -o, --outfile=FILE               write output text to FILE
        -V, --version                    show version number and exit

### sanzang-translate

The program sanzang-translate (1) reads a translation table file, (2) applies
this table's rules to an input text, and then (3) generates a translation
listing. This program can also run in a special batch mode that can utilize
multiprocessing (multiple processors and processor cores) for high
performance.

    Usage: sanzang-translate [options] table
    Usage: sanzang-translate -B output_dir table < file_list

    Options:
        -h, --help                       show this help message and exit
        -B, --batch-dir=DIR              process from a queue into DIR
        -E, --encoding=ENC               set data encoding to ENC
        -L, --list-encodings             list possible encodings
        -i, --infile=FILE                read input text from FILE
        -o, --outfile=FILE               write output text to FILE
        -P, --platform                   show platform information
        -V, --version                    show version number and exit

Basic Usage
-----------

### Formatting and translating a single text

In the following example, we are working with a small text that we want to
translate. With the first command, we reformat the text using sanzang-reflow.
Then we run the sanzang-translate program with our translation table, to
generate a translation listing.

    $ sanzang-reflow -i xinjing.txt -o lines.txt
    $ sanzang-translate -i lines.txt -o trans.txt TABLE.txt

### Redirecting I/O

The next two commands illustrate how these programs use standard input and
output streams by default, and how they can easily operate as text filters.

    $ sanzang-reflow -i xinjing.txt | sanzang-translate -o trans.txt TABLE.txt
    $ cat xinjing.txt | sanzang-reflow | sanzang-translate TABLE.txt | less

Advanced Usage
--------------

### Batch Mode and Multiprocessing

In the following example, we may have several thousand texts that we want to
run through sanzang-translate with our translation table. For example, if our
translation table was updated recently, we may want to regenerate our corpus
of translation listings. To do this, we can use the "find" command to retrieve
the file paths to our text files, and then pipe that output into the Sanzang
translation program.

    $ find /srv/texts -type f | sanzang-translate -B /srv/trans TABLE.txt

This command will find all files in the location specified, and then feed the
file paths to sanzang-translate, which will process them as a batch. If the
"parallel" gem is available and functioning on the system, then the batch will
be divided among all available processors.

If this gem has been installed, then when running in batch mode, if we have six
CPU cores on the local machine, then we should be able to expect six
translation processes running concurrently. The exception to this is on the
"mswin" and "mingw" platforms, which do not have the necessary system calls
for Unix style multiprocessing. In this case, running Sanzang in the
Cygwin environment is a viable alternative.

The performance benefits of running with the "parallel" library can be very
significant, leading to a series of translation listings being generated in a
mere fraction of the time it would take to process them otherwise. This
performance gain is typically proportional to the number of processors and
processor cores available on the local system.

### Text Encodings

Sanzang supports many possible text encodings. Option "-L" will list all
available text encodings. Option "-E" will set the encoding to be used for all
text data such as input texts, output texts, and table files. The other program
I/O, such as messages for the terminal, will still be in the default encoding
of the environment. For example, in a Windows environment that by default uses
the IBM-437 encoding, specifying "-E" with a value of "UTF-16LE" will cause
Sanzang to read and write all text data in UTF-16LE, but all other program
messages will still be displayed in the console's native IBM-437 encoding.

    $ sanzang-translate -E UTF-16LE -i in.txt -o out.txt TABLE.txt

If the "-E" option is not specified, then Sanzang will use the default encoding
inherited from the environment. For example, a GNU/Linux user running Sanzang in
a UTF-8 terminal will by default have all text data read and written to in the
UTF-8 encoding. The one *exception* to this is for environments using the
IBM-437 encoding (typically an old Windows command shell). In this case,
Sanzang will take pity on you and automatically switch to UTF-8 by default, as
if you had specified the option "-E" with value "UTF-8".

Responsible Use
---------------

With comprehensive translation tables, Sanzang can often be quite accurate
and effective. However, this program is still comparable to a simple machine,
and it can never replace a human translator. Please understand the scope of
this translation system when using it. No machines can take responsibility for
a poor translation. In the end, it is you who are responsible for any and all
publications.
