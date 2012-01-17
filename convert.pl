    #!/opt/local/bin/perl  
    use strict;  
    use warnings;  
    use XML::Twig;  
    use utf8;  
    use Data::Dumper;  
    use HTML::Entities;  
    binmode STDOUT, ":utf8";  
    binmode STDERR, ":utf8";  
    #require 'Kana.pl';#kana2romaji  
      
    open(XML, '>', "wadoku.html") or die $!;  
    binmode XML, ":utf8";  
    # print XML qq'<?xml version="1.0" encoding="UTF-8"?>\n';  
    # print XML qq'<d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">\n';  
    my $i=0;  
      
    my $t = XML::Twig->new(  
        twig_handlers => {  
            entry => \&entry  
        }  
    );  
    $t->parsefile( 'wadoku2012.xml');  
    # print XML qq'</d:dictionary>';  
    close XML; 

	sub exist
	{
		my $elements   = $_[1];
		my $element = $_[0];
		my $is_element = 0;
	
		foreach my $element_i(@$elements)
		{
			# if(defined $element_i) {
		if($element_i eq $element)
		{
			$is_element = 1;
		}
		# } 
		}
	$is_element;
	}	
      
    sub flatten   
    {  
        my ($t) = @_;  
          
        if($t->has_children()) {  
            my @children = $t->children();  
            my $output = "";  
            foreach my $c (@children) {  
                if($c->tag eq 'token')   
                {  
                    my $type = $c->att('type')||"N";  
                    die "bad type: $type\n" if $type ne 'N';  
                    my $gen = $c->att('genus') || "";  
                    my $num = $c->att('numerus')||"";  
                    if("$gen$num" ne "") {  
                        $output .= flatten($c)."<sup>$gen</sup>";
                    } else{  
                        $output .= flatten($c);
                    }  
                } elsif($c->tag eq 'text') {  
                    my $nach = $c->att('hasFollowingSpace')||"";  
                    my $vor = $c->att('hasPrecedingSpace')||"";  
                    $output .= " " if $vor;  
                    $output .= flatten($c);  
                    $output .= " " if $nach;  
                } elsif($c->tag eq 'bracket') {  
                    my $x = flatten($c);  
                    $x =~ s!;? $!!;  
                    $output .= "($x)";  
                } elsif($c->tag eq 'tr') {  
                    $output .= flatten($c)."; ";  
                } elsif($c->tag eq 'def') {  
                    $output .= flatten($c)."; ";  
                } elsif($c->tag eq '#PCDATA') {  
                    $output .= encode_entities($c->text,'<>&"');  
                } elsif($c->tag eq 'ref') {  
                    my $id = $c->att('id');  
                    my $type = $c->att('type');  
                    my $jap = $c->first_child('jap');  
                    if((not defined $jap) || (not defined $type)) {  
                            my $x = flatten($c);  
                            $output .= "$x";  
                            #print "\n$x\n";  
                            #print "\n";  
                            #$c->print;  
                            #print "\n";  
                            #$t->print;  
                            #print "\n";  
                            #die "not ref";  
                    } else {          
                        $jap = flatten($jap);  
                        $type =~ s!^altread$!→!;  
                        $type =~ s!^syn$!⇒!;  
                        $type =~ s!^anto$!⇔!;  
						$output .= "<a href=\"#$jap\">$type ($jap)</a> ";  
                        # if(defined $id) {  
                            # $output .= qq!<a href="x-dictionary:r:wadoku$id">$type ($jap)</a>; !;  
                        #} else {  
                            
                        #}  
                    }  
                } elsif($c->tag eq 'foreign') {  
                    $output .=  " ".flatten($c)." ";  
                } elsif($c->tag eq 'emph') {  
                    $output .=  '<i>'.flatten($c)."</i>";  
                } elsif($c->tag eq 'etym') {  
                    $output .=  '<i>'.flatten($c)." </i>";  
                } elsif($c->tag eq 'title') {  
                    $output .=  '<i>'.flatten($c)." </i>";  
                } elsif($c->tag eq 'date') {  
                    $output .=  flatten($c)." ";  
                } elsif($c->tag eq 'birthdeath') {  
                    $output .=  flatten($c);  
                } elsif($c->tag eq 'impli') {  
                        #keine ausgabe  
                } elsif($c->tag eq 'usg') {  
                        my $type = $c->att('type')||"";  
                        my $reg = $c->att('reg');  
                        if($type eq "") {  
                            if(not defined $reg) {  
                                #print "\n";  
                                #$c->print;  
                                #print "\n";  
                                #$t->print;  
                                #print "\n";  
                                #die "no reg";  
                            } else {  
                                $reg = ucfirst $reg;  
                                $output .= $reg." ";  
                            }  
                        } else {  
                        if($type eq 'hint') {  
                            $output .= "|| ";  
                        }   
                        elsif($type eq 'dom') {  
                            $output .=  flatten($c)." ";  
                        }  
                        elsif($type eq 'abrev') {  
                            $output .=  '<i>'.flatten($c)." </i>";  
                        }  
                        elsif($type eq 'time') {  
                            $output .=  flatten($c)." ";  
                        }  
                        else {  
                            print "\n";  
                            $c->print;  
                            print "\n";  
                            $t->print;  
                            print "\n";  
                            die "rel $type";  
                        }  
                        }  
                } else {  
                    my $x =  flatten($c)." ";  
                    $output .= $x;  
                    if($c->tag ne 'trans'  
                    && $c->tag ne 'expl'  
                    && $c->tag ne 'famn'  
                    && $c->tag ne 'transl'  
                    && $c->tag ne 'topic'  
                    && $c->tag ne 'literal'  
                    && $c->tag ne 'deu_gr'  
                    && $c->tag ne 'specchar'  
                    && $c->tag ne 'iron'  
                    && $c->tag ne 'jap'  
                    && $c->tag ne 'descr'  
                    && $c->tag ne 'transcr'
					&& $c->tag ne 'link'
					&& $c->tag ne 'expli') {  
                        print "\n".$c->tag;  
                        print "\n";  
                        $c->print;  
                        print "\n";  
                        $t->print;  
                        print "\n";  
                        print "$output\n";  
                        die "handle me";  
                        #$c->print;  
                        #print "\nx: $output\n";  
                    }  
                }  
            }  
            return $output;  
        }   
        else {  
            return $t->text();  
        }  
    }  
      
    sub entry   
    {  
        my ($t, $entry) = @_;  
          
        my $id = $entry->att('id');  
        if((not defined $id) || (not $id =~ m!^[0-9]+$!)) {  
            $entry->print;  
            exit;  
        }  
          
        my @form = $entry->children('form');  
          
        if(length @form != 1) {  
            $entry->print;  
            exit;  
        }  
          
        my @orth = $form[0]->children('orth');  
        if(length @orth < 1) {  
            $entry->print;  
            exit;  
        }     
          
        my @pron = $form[0]->children('pron');  
        if(length @pron < 1) {  
            $entry->print;  
            exit;  
        }  
          
        my $lemma = undef;  
        my $schreibweise = "";  
        foreach my $orth (@orth) {  
            my $o = $orth->text;  
            my $is_lemma = $orth->att('midashigo') || "";  
            $lemma = $o if $is_lemma or not defined $lemma;  
            my $is_irr = $orth->att('irr') || "";  
            $schreibweise .= "$o; ";  
        }  
        $schreibweise =~ s!; $!!;  
          
        if(not defined $lemma) {  
            $entry->print;  
            exit;  
        }  
          
        $lemma =~ s!×!!g;  
        $lemma =~ s!△!!g;  
        $lemma = encode_entities($lemma,'<>&"');  
        #print "lemma: $lemma\n";  
          
		  
		# aussprache 
		# wird unverändert hiragana teil des entry
        # my $aussprache = undef;  
        my $aussprache = undef;  
        foreach my $pron (@pron) {  
            my $is_hatsuon = $pron->att('type') || "";  
            if($is_hatsuon eq "hatsuon") {  
                my $p = $pron->text;
				
				
            $p =~ s!×!!g;  
            $p =~ s!△!!g;  
            $p =~ s!〈!!g;  
            $p =~ s!〉!!g;  
            $p =~ s!\{([^ ]+)\}!$1!g;  
            $p =~ s!\[[^]]*\]!!g;  
            $p =~ s!＿!!g;  
            $p =~ s!'!!g;  
            $p =~ s!･!!g;  
            $p =~ s!/!!g;  
            $p =~ s!<!!g;  
            $p =~ s!>!!g;  
            $p =~ s!’!!g;  
            $p =~ s!・!!g;  
            $p =~ s!~!!g;  
			$aussprache = $p;
            }  
        }      
		
				      
		if(not defined $aussprache) {  
			foreach my $pron (@pron) {  
				my $p = $pron->text;  
            $p =~ s!×!!g;  
            $p =~ s!△!!g;  
            $p =~ s!〈!!g;  
            $p =~ s!〉!!g;  
            $p =~ s!\{([^ ]+)\}!$1!g;  
            $p =~ s!\[[^]]*\]!!g;  
            $p =~ s!＿!!g;  
            $p =~ s!'!!g;  
            $p =~ s!･!!g;  
            $p =~ s!/!!g;  
            $p =~ s!<!!g;  
            $p =~ s!>!!g;  
            $p =~ s!’!!g;  
            $p =~ s!・!!g;  
            $p =~ s!~!!g;   
			if(not defined $aussprache) {
				$aussprache = $p;  }
			}  
		}  
      
		die "keine aussprache/lesung \n" if not defined $aussprache;  
 
          
        my @sense = $entry->children('sense');  
        if(length @sense < 1) {  
            $entry->print;  
            exit;  
        }
        
		my $index_lesung;
          
		# sollte nur eine geben
		# überprüfen!
        foreach my $pron (@pron) {  
            my $p = $pron->text;  
            my $is_hatsuon= $pron->att('type'); # || "";  
            if(not $is_hatsuon) {  
			$p =~ s!…!!g;  
			$p =~ s!×!!g;  
            $p =~ s!△!!g;  
            $p =~ s!〈!!g;  
            $p =~ s!〉!!g;  
            $p =~ s!\{([^ ]+)\}!$1!g;  
            $p =~ s!'!!g;  
            $p =~ s!\[[^]]*\]!!g;  
            $p =~ s!/!!g;  
            $p =~ s!<!!g;  
            $p =~ s!>!!g;  
            $p =~ s!\s+!!g;  
            $p =~ s!･!!g;  
            $p =~ s!＿!!g;  
            $p =~ s!’!!g;  
            $p =~ s!…!!g;  
            $p =~ s!~!!g;  
				$index_lesung = $p;
            }			
        }    
		die "kein index für lesung\n" if not defined $index_lesung;  
                
		
        # print XML qq!<d:entry id="wadoku$id" d:title="$lemma">!;
        print XML "<dt>";
		print XML $aussprache." ";
				
		# sammel alle schreibweisen zum indizieren in array
		# sammel gleichzeitig alle schreibweisen + extra infos 
		#    zur darstellung in entry
		my @lesungen_index = ();
		my @lesungen_entry = ();
        foreach my $orth (@orth) {  		   
            my $o = $orth->text;  
			if($o ne $aussprache && (exist($o,\@lesungen_entry) eq 0)) { push(@lesungen_entry,$o); }
			
            $o =~ s!…!!g;  
            # $o =~ s!×!!g;  
            # $o =~ s!△!!g;  
            $o =~ s!〈!!g;  
            $o =~ s!〉!!g;  
            $o =~ s!\{([^ ]+)\}!$1!g;  
            if($o =~ m!\([^)]*\)!) {  
                while($o =~ s!([^;]*)\(([^)]*)\)([^;]*)!$1$2$3;$1$3!g) {};  
            }  
            my @x = split ";",  $o;  
            foreach my $x (@x)  {  
				if($o ne $aussprache && (exist($x,\@lesungen_index) eq 0)) { push(@lesungen_index,$x); }
            }  
        }  
		my $lesungen_entry_string = "";
		foreach my $lesung_i(@lesungen_index) {
			if($lesungen_entry_string eq "") { 
				$lesungen_entry_string = $lesung_i;
			} else {
			$lesungen_entry_string = $lesungen_entry_string.";".$lesung_i;
			}
		}
		if($lesungen_entry_string ne "") { print XML "【$lesungen_entry_string】" };
		print XML "</dt>";  
		
		print XML '<key type="かな">'.$index_lesung.'</key>';		
		foreach my $lesung_i_index(@lesungen_index) {
		    print XML '<key type="表記">'.$lesung_i_index.'</key>';		
		}
		if(not @lesungen_index) {
			print XML '<key type="表記">'.$index_lesung.'</key>';		
		}
		
		
		print XML "<dd>";  		
        foreach my $pron (@pron) {  
            my $p = $pron->text;  
            my $is_hatsuon= $pron->att('type') || "";  
              
            if(not $is_hatsuon) {  
                #my $romaji = kana2romaji($p);  
                #$romaji =~ s!u゛x(.)!v$1!g;  
                #$romaji =~ s!　! !g;  
                #$romaji =~ s!、!,!g;  
                #$romaji =~ s!。!.!g;  
                $p = encode_entities($p,'<>&"');  
                #$romaji = encode_entities($romaji,'<>&"');  
                # print XML qq!<d:index d:title="$lemma" d:value="$p" d:yomi="$yomi"/>!;  
                #print XML qq!<d:index d:title="$lemma" d:value="$romaji" d:yomi="$yomi"/>!;  
            }  
        }  
          
        my $bedeutung = "";  
        my $cnt=0;  
        my $ms = @sense;  
        foreach my $sense (@sense) {  
                my $eintrag = flatten($sense);  
                $eintrag =~ s!;\s*$!!;  
                $cnt++;  
                $bedeutung .= " " if $ms>1 && $cnt!=1;  
                
                $bedeutung .= "[$cnt] " if $ms>1;  
                $bedeutung .= $eintrag;  
                
        }  
          
		$bedeutung =~ s!\n!!g;  
     	print XML "$bedeutung";;  
        print XML "</dd>\n";  		  
        
		$entry->purge;  
        return 1;  
    }  