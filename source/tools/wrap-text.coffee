do ()->

  # This is a basic text-wrapping utility that works fine for monospace,
  # but does not account for text metrics with variable width fonts.

  Make "WrapText", WrapText = (string, maxLineLength)->
    return [] unless string? and string.length > 0

    lines = []
    currentLine = 0
    lineLength = 0

    words = string.split " "

    while words.length > 0
      currentWord = words.shift()

      # If there's already stuff on the current line,
      # and the current word would push us past the right edge,
      # start a new line
      if lines[currentLine]? && lineLength + currentWord.length > maxLineLength
        currentLine++

      # If the current line is empty, set it up
      if not lines[currentLine]
        lines[currentLine] = []
        lineLength = 0

      # Add the current word to the current line
      lines[currentLine].push currentWord

      # Update the length of the current line
      lineLength += currentWord.length

      # Also count spaces between words
      lineLength += 1 if lines[currentLine].length > 1

    for line, i in lines
      lines[i] = line.join " "

    return lines
