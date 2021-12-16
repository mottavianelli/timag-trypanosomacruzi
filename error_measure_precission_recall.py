def xml_to_coords(xml, markerType):
    with open(xml, 'r') as f:
        data = f.read()
    Bs_data = BeautifulSoup(data, "xml")
    b_MarkerX = Bs_data.find_all('MarkerX')
    b_MarkerY = Bs_data.find_all('MarkerY')
    #print(b_MarkerX)

    xCoords = []
    for marker in b_MarkerX:
        Marker_Type = marker.find_parent('Marker_Type')
        #print(markerType == Marker_Type.Type.string)
        if Marker_Type.Type.string == markerType:
            xCoord = marker.string
            xCoords.append(np.int(xCoord))

    yCoords = []
    for marker in b_MarkerY:
        Marker_Type = marker.find_parent('Marker_Type')
        if Marker_Type.Type.string == markerType:
            yCoord = marker.string
            yCoords.append(np.int(yCoord))

    coords = np.vstack((yCoords,xCoords)).T
    return coords

def etiquetar(dst):
    img = cv2.threshold(dst, 127, 255, cv2.THRESH_BINARY)[1]
    num_labels, labels=cv2.connectedComponents(img)
    return num_labels, labels

def true_positives_and_false_negatives(img, coords):
    img_labels, labs=etiquetar(img)
    nlabels = coords.shape[0]
    true_positives = 0 
    false_negatives = 0
    M, N = img.shape
    etiq_usadas=[]
    print('n: ', nlabels)
    for n in range(nlabels):
        if ((img[coords[n][0], coords[n][1]] != 0) and np.all(labs[coords[n][0], coords[n][1]]!=etiq_usadas)):   ### si no es negro
            true_positives+=1
            etiq_usadas.append(labs[coords[n][0], coords[n][1]])
        else:
            false_negatives+=1
    return true_positives, false_negatives

def false_positives(path, true_positives):
    file = open(path)
    csvreader = csv.reader(file)
    data = np.array(list(csvreader))
    total = data.shape[0]-1
    print('Total labels fiji: ', total)
    return total-true_positives
    
    
def precission_recall(true_positives, false_positives, false_negatives)
    precission = true_positives/(true_positives + false_positives)
    recall = true_positives/(true_positives + false_negatives)
    return precission, recall