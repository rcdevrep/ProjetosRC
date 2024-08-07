#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} NXMT100L

Substitui MT100LOK no Patch SHELL         
Chamado 72549 - Bloqueio de CC na entrada da nota conforme campo CT1_CCOBRG
@author N/A
@since N/A
@version 1
@type function
/*/

User Function NXMT100L

	Local lRet       := .T.
	Local nPosCC     := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CC"})
	Local nPosCont   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CONTA"})
	Local cPed1      := ""
	Local cPed2      := ""  

	//Chamado 72549 - Bloqueio de CC na entrada da nota
	If Posicione('CT1',1,xfilial('CT1')+aCols[n][nPosCont],'CT1_CCOBRG') == '1'
		If alltrim(aCols[n][nPosCC]) == ""
			alert('Centro de Custo obrigat�rio para essa conta, Favor preench�-lo!')
			lRet := .F.
		Endif
	Endif  

Return lRet