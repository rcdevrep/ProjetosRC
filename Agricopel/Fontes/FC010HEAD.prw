#INCLUDE "PROTHEUS.CH"

User function FC010HEAD()

Local aHeader := Paramixb

AltStruct()

Return aHeader

Static Function AltStruct()


Local l := 0
public aMoeda := {}
public aNotas := {}
public aAux   := aHeader


For l := 1 To 10
     aHeader[13][l] := aHeader[14][l]
     aHeader[14][l] := aHeader[20][l]
     aHeader[16][l] := aHeader[19][l]
     aHeader[19][l] := Paramixb[16][l]
     aHeader[17][l] := Paramixb[13][l]

Next l     

Return
