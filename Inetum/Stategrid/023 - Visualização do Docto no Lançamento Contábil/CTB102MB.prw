#INCLUDE "TOTVS.CH"
#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "FWMVCDef.ch"
#INCLUDE "Jpeg.CH"
#INCLUDE "topconn.ch" 

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Data      |     Autor       |       Descrição
 2024/07/01   | Jader Berto     | Utilizado ponto de entrada que usuario filtra a tabela CT2 na mBrowse
                                   para incluir opção de menu na rotina CTBA101
								   Com objetivo de buscar anexo(s) relacionado à origem do lançamento contábil
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function CTB102MB()
	Private cIdioma := RetAcsName()
	Private cMsg11  :=''

	If cIdioma == ".ACS"
		cMsg11  :='Exibir Anexo'
	else
		cMsg11  :='View Attachment'
	endif

	aAdd(aRotina, {cMsg11,       'U_ALLANEXO()',      0, 2, 0, NIL})
return 
