#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#include "rwmake.ch"                                                                       	
#include "topconn.ch"       
#include 'Protheus.ch'






User Function AGX600()      

Local cAlias := "ZZW"
Local cTitulo := "Parametros de Clientes Auxiliar"
Local cVldExc := ".T."
Local cVldAlt := ".T."
dbSelectArea(cAlias)
dbSetOrder(1)
AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)


Return()

