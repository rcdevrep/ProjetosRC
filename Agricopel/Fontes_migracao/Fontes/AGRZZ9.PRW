#INCLUDE "RWMAKE.CH"  
#INCLUDE "PROTHEUS.CH"


//-----------------------------------------+
// AUTOR: LAYZE RIBAS   | DATA: 07/03/2016 |
//-----------------------------------------+
// AXCADASTRO MENU CADASTRO GENERICO PARA  |
// IMPORTACAO DO AUTOSYSTEM                |
//-----------------------------------------+

User Function AGRZZ9 ()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZ9"

dbSelectArea("ZZ9")
dbSetOrder(1)

AxCadastro(cString,"Cadastro Genérico Autosystem",cVldExc,cVldAlt)

Return
