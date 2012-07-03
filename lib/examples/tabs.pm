package examples::tabs;
use Dancer ':syntax';
use strict;
use warnings;

=pod
This example demonstrates Bootstrap's Navigation tabs/pills, with dynamic content generation.
=cut

my @books = (
	{ title  => "PRIDE AND PREJUDICE",
	  uuid   => "pride_and_prejudice",
	  author => "Jane Austen",
	  url    => "http://www.gutenberg.org/ebooks/1342",
	  chapter_title => "Chapter 1",
	  excerpt => "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.

However little known the feelings or views of such a man may be on his first entering a neighbourhood, this truth is so well fixed in the minds of the surrounding families, that he is considered the rightful property of some one or other of their daughters.

\"My dear Mr. Bennet,\" said his lady to him one day, \"have you heard that Netherfield Park is let at last?\"

Mr. Bennet replied that he had not.

\"But it is,\" returned she; \"for Mrs. Long has just been here, and she told me all about it.\"

Mr. Bennet made no answer."
	 },


	{
	  title => "THE ADVENTURES OF SHERLOCK HOLMES",
	  uuid  => "sherklock_holmes",
	  author=> "SIR ARTHUR CONAN DOYLE",
	  url   => "http://www.gutenberg.org/ebooks/1661",
	  chapter_title => "ADVENTURE I. A SCANDAL IN BOHEMIA",
	  excerpt=> "To Sherlock Holmes she is always THE woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex. It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, precise but admirably balanced mind. He was, I take it, the most perfect reasoning and observing machine that the world has seen, but as a lover he would have placed himself in a false position. He never spoke of the softer passions, save with a gibe and a sneer. They were admirable things for the observer--excellent for drawing the veil from men's motives and actions. But for the trained reasoner to admit such intrusions into his own delicate and finely adjusted temperament was to introduce a distracting factor which might throw a doubt upon all his mental results. Grit in a sensitive instrument, or a crack in one of his own high-power lenses, would not be more disturbing than a strong emotion in a nature such as his. And yet there was but one woman to him, and that woman was the late Irene Adler, of dubious and questionable
memory.",
	},

	{
	  title => "ULYSSES",
	  uuid  => "ulysses",
	  author=> "James Joyce",
	  url   => "http://www.gutenberg.org/ebooks/4300",
	  chapter_title => "-- I --",
	  excerpt=> "Stately, plump Buck Mulligan came from the stairhead, bearing a bowl of lather on which a mirror and a razor lay crossed. A yellow dressinggown, ungirdled, was sustained gently behind him on the mild morning air. He held the bowl aloft and intoned:

--Introibo ad altare Dei.

Halted, he peered down the dark winding stairs and called out coarsely:

--Come up, Kinch! Come up, you fearful jesuit!

Solemnly he came forward and mounted the round gunrest. He faced about and blessed gravely thrice the tower, the surrounding land and the awaking mountains. Then, catching sight of Stephen Dedalus, he bent towards him and made rapid crosses in the air, gurgling in his throat and shaking his head. Stephen Dedalus, displeased and sleepy, leaned his arms on the top of the staircase and looked coldly at the shaking gurgling face that blessed him, equine in its length, and at the light untonsured hair, grained and hued like pale oak. 

Buck Mulligan peeped an instant under the mirror and then covered the bowl smartly."
	},
	{
	 title => "ADVENTURES OF HUCKLEBERRY FINN",
         uuid  => "huck_finn",
	 author => "Mark Twain",
	 url => "http://www.gutenberg.org/cache/epub/76/pg76.txt",
	 chapter_title => "CHAPTER I.",
 	 excerpt => "YOU don't know about me without you have read a book by the name of The Adventures of Tom Sawyer; but that ain't no matter.  That book was made by Mr. Mark Twain, and he told the truth, mainly.  There was things which he stretched, but mainly he told the truth.  That is nothing.  I never seen anybody but lied one time or another, without it was Aunt Polly, or the widow, or maybe Mary.  Aunt Polly--Tom's Aunt Polly, she is--and Mary, and the Widow Douglas is all told about in that book, which is mostly a true book, with some stretchers, as I said before."
	}

) ;

get '/tabs' => sub {
	# Crude and explicit input validation.
	# By default, the user hasn't set any CGI parameters, so use non-stacked tabs.
	my $stacked = param 'stacked';
	$stacked = 0 unless defined $stacked;
	$stacked = 0 unless $stacked == 0 || $stacked == 1;
	my $type = param 'navtype';
	$type = "tabs" unless defined $type;
	$type = "tabs" unless $type eq "tabs" || $type eq "pills";

	template 'examples/tabs', { books => \@books, stacked => $stacked, navtype => $type };
};

true;
