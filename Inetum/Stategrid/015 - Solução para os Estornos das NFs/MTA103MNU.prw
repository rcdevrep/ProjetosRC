
#Include "PROTHEUS.CH" 

User Function MTA103MNU

aadd( aRotina, { "Anexos" , "U_TOTVSANEXO(cEmpAnt,cFilAnt,'NF',F1_DOC+F1_SERIE+F1_FORNECE+ALLTRIM(F1_LOJA))" , 0 , 6}  )
aadd( aRotina, { "Rejeitar Classif" , "U_STAA051(SF1->(RECNO()),ALLTRIM(SF1->F1_XSOLIC))" , 0 , 6}  )
aadd( aRotina, { "Formul�rio de ODI" , "U_RELODI()" , 0 , 6}  )
aadd( aRotina, { "Ajustes DIFAL e ISS" , "U_STAA075()" , 0 , 6}  )
aadd( aRotina, { "Ajustes PIS e COFINS" , "U_STAA099()" , 0 , 6}  )
// Ponto de chamada Conex�oNF-e
// Insere no menu do documento de entrada a consulta das cartas de corre��o.
U_GTPE010()

return
