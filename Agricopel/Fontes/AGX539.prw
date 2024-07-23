#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"




User Function AGX539()     

Local cAlias := "ZZO"
Local cTitulo := "Cadastro de Embarcações"
Local cVldExc := ".T."
Local cVldAlt := ".T."
dbSelectArea(cAlias)
dbSetOrder(1)



	AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)
Return nil