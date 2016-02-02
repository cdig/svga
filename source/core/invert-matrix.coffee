invert = (matrix)->
  if matrix.length isnt matrix[0].length
    return
  identity = []
  copy = []
  dim = matrix.length
  for i in [0..dim - 1]
    identity[i] = []
    copy[i] = []
    for j in [0..dim - 1]
      if i is j
        identity[i][j] = 1
      else
        identity[i][j] = 0
      copy[i][j] = matrix[i][j]

  #perform row operations
  for i in [0..dim - 1]
    temp = copy[i][i]
    if temp is 0
      for ii in [0..dim - 1]
        for j in [0..dim - 1]
          if copy[ii][i] isnt 0
            temp = copy[i][j]
            copy[i][j] = copy[ii][j]
            copy[ii][j] = temp
            temp = identity[i][j]
            identity[i][j] = identity[ii][j]                        
            identity[ii][j] = temp
          break
      temp = copy[i][i]
    
    for j in [0..dim-1]
      copy[i][j] = copy[i][j]/temp
      identity[i][j] = identity[i][j]/temp

    for ii in [0..dim-1]
      if ii is i
        continue
      temp = copy[ii][i]

      for j in [0..dim-1]
        copy[ii][j] -= temp * copy[i][j]
        identity[ii][j] -= temp * identity[i][j]
  
  return identity


invertSVGMatrix = (matrixString)->
  matches = matrixString.match(/[+-]?\d+(\.\d+)?/g)
  matrix = []
  for i in [0..2]
    matrix.push [0, 0, 0]

  matrix[0][0] = parseFloat(matches[0])
  matrix[0][1] = parseFloat(matches[1])
  matrix[0][2] = parseFloat(matches[4])

  matrix[1][0] = parseFloat(matches[2])
  matrix[1][1] = parseFloat(matches[3])
  matrix[1][2] = parseFloat(matches[5])
  matrix[2][0] = 0
  matrix[2][1] = 0
  matrix[2][2] = 1
  newMatrix = invert(matrix)
  matrixString = "matrix(#{newMatrix[0][0]}, #{newMatrix[0][1]}, #{newMatrix[1][0]}, #{newMatrix[1][1]}, #{newMatrix[0][2]}, #{newMatrix[1][2]})"
  return matrixString
