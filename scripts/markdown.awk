#!/usr/bin/awk -f

BEGIN {
    inCodeBlock = 0
    inLink = 0
    inTable = 0
}

# Headers
/^#{1,6}[[:space:]]/ {
    level = length($0)
    gsub(/^[#[:space:]]+|[[:space:]]+$/, "")
    print "<h" level ">" $0 "</h" level ">"
    next
}

# Lists
/^[*-][[:space:]]/ {
    if (!inList) {
        print "<ul>"
        inList = 1
    }
    gsub(/^[*-][[:space:]]/, "")
    print "<li>" $0 "</li>"
    next
}

# Code Block
/^[[:space:]]{4}/ {
    if (!inCodeBlock) {
        print "<pre><code>"
        inCodeBlock = 1
    }
    print $0
    next
}

# Hyperlinks
/\[.*\]\(.*\)/ {
    linkText = gensub(/\[|\]\(.*\)/, "", "g")
    linkURL = gensub(/.*\(|\)/, "", "g")
    print "<a href=\"" linkURL "\">" linkText
    inLink = 1
    next
}

# Images
/!\[.*\]\(.*\)/ {
    altText = gensub(/!\[|\]/, "", "g")
    imgURL = gensub(/.*\(|\)/, "", "g")
    print "<img src=\"" imgURL "\" alt=\"" altText "\">"
    next
}

# Tables
/^[\|].*[\|]$/ {
    if (!inTable) {
        print "<table>"
        inTable = 1
    }
    gsub(/^[ ]*\|/, "")
    gsub(/\|[ ]*$/, "")
    if (NR == 1) {
        print "<thead>"
    } else if (NR == 2) {
        print "<tbody>"
    }
    print "<tr>"
    n = split($0, cells, "|")
    for (i = 1; i <= n; i++) {
        if (NR == 1) {
            print "<th>" cells[i] "</th>"
        } else {
            print "<td>" cells[i] "</td>"
        }
    }
    print "</tr>"
    next
}

# End of Code Block
inCodeBlock && /^[^[:space:]]/ {
    print "</code></pre>"
    inCodeBlock = 0
}

# Paragraphs
/^[[:space:]]*$/ {
    if (inList) {
        print "</ul>"
        inList = 0
    }
    if (inCodeBlock) {
        print "</code></pre>"
        inCodeBlock = 0
    }
    next
}

# Inline Code
/`[^`]+`/ {
    gsub(/`/, "")
    print "<code>" $0 "</code>"
    next
}

# Bold and Italics
{
    sub(/\*\*\*/, "<strong><em>", $0)
    sub(/\*\*\*/, "</em></strong>", $0)
    sub(/\*\*/, "<strong>", $0)
    sub(/\*\*/, "</strong>", $0)
    sub(/\*([^*]+)\*/, "<em>\\1</em>", $0)
    print "<p>" $0 "</p>"
}

END {
    if (inList) {
        print "</ul>"
    }
    if (inCodeBlock) {
        print "</code></pre>"
    }
    if (inLink) {
        print "</a>"
    }
}

