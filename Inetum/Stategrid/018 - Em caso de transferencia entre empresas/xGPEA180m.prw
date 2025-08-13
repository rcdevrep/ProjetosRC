#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Data      |     Autor       |       Descrição
 2024/05/23   | Filipe Oliveira |  Função chamada no Gatilho RA_FILIAL , para gerar nova matricula sequencial
                                    referente à empresa e filial selecionada a ser transferido Funcionário.                                    
 2024/05/27   | Jader Berto     | Otimização com função NextNumero, substituindo query e GexSxenum                                     
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
User Function xGPEA180m()    
    Local cMat    :=""
    Local aArea   := GetArea()

    If IsNumeric(M->RA_FILIAL) .AND. Len(M->RA_FILIAL)==4     
        If M->RA_FILIAL != aTransfcols[1][4]
            //cMat := NextNumero("SRA", 1, "RA_MAT", .T.) 
            cMat    := U_xFSeq(M->RA_FILIAL)
        else
            cMat := M->RA_MAT   
        EndIf     
    EndIf
    RestArea(aArea)
Return cMat


User Function xFSeq(xFil)
Local cXMat := "000001"
Local nTam  := 0

	cQuery := "SELECT MAX(SRA.RA_MAT) MAT, LEN(MAX(SRA.RA_MAT)) TAM FROM "+RetSqlName("SRA")+" SRA "+CRLF
	cQuery += " WHERE SUBSTRING(SRA.RA_MAT, 1,1) < '8' "+CRLF
	cQuery += "  AND SRA.RA_FILIAL = '"+xFil+"' "+CRLF
	cQuery += "  AND SRA.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  AND LEN(SRA.RA_MAT) = 6 "+CRLF

    /*
    If !ExistDir("c:\temp")
       MakeDir("c:\temp")
    EndIf
    MemoWrite("c:\temp\query_SRA.sql", cQuery)
    */
	If Select("TMPX") > 0 
		dbSelectArea("TMPX")
		TMPX->(dbCloseArea())
	EndIf

	TCQUERY cQuery Alias TMPX NEW
	If TMPX->(!EOF())	
        If Empty(TMPX->MAT)
            cXMat := "000001"
        Else
            cXMat := val(TMPX->MAT)+1
            nTam  := TMPX->TAM
            cXMat := STRZERO(cXMat,nTam)
        EndIf
    else
        cXMat := "000001"
    endIf
	
    TMPX->(dbCloseArea())

Return cXMat
