#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "Topconn.ch"


User Function XAGORUS()

    Local cPath := "app_incpv.log"
    Local oFile 
    Local aAux  := {}
	Local cMsg  := ""
	Local I     := 0 
    Local cPedidos := ""
    Local nPosPed  := 2
    Local cRetorno := ""

    cRetorno := FWInputBox("Qual Log? Digite: P para pedidos ou V para visitas", " ")

    If !(cFilAnt $ '06/19')
        Alert('Rotina so pode ser utilizada pelas filiais 06 e 19')
        Return 
    Endif 

    If alltrim(cRetorno) == 'P'
        cPath := "app_incpv.log"
    Elseif alltrim(cRetorno) == 'V'
        cPath := "app_incpv_ad7.log"
    Else
        Alert("Invalido: Digite: P para pedidos ou V para visitas ")
        Return
    Endif 
        

    cPathTmp := GetTempPath() 

    __CopyFile("\spool\"+cPath, cPathTmp+cPath)

    oFile := FwFileReader():New(cPathTmp+cPath)

	//if FILE(cPathTmp+cPath)
	//	Alert("Achou o arquivo")
	//Endif 
    
 // SE FOR POSSÍVEL ABRIR O ARQUIVO, LEIA-O
    // SE NÃO, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        aAux := oFile:GetAllLines() // ACESSA TODAS AS LINHAS

        If cRetorno = 'P'
            //Varre TXT
            For I := 1 to len(aAux)
                aLinha := separa(aAux[I],';')

                //Ignora linhas em Branco
                If len(aLinha) == 0 
                    //Alert('Não gerou a linha')
                    loop
                Endif 

                If alltrim(aLinha[1]) == 'INCLUSAO'
                    nPosPed := 5
                Elseif alltrim(aLinha[1]) == 'CONSULTA'
                    loop
                Else
                    nPosPed := 2 
                Endif 
            

                //Data: 01/04/22 hora: 12:13:43 - pedido: 20220401115742RL0260;925885
                //INCLUSAO;01/04/22;14:02:12;20220401135915RL0211;925890
                //CONSULTA;01/04/22;14:02:27;20220401135915RL0211;925890

                Dbselectarea('SC5')
                Dbsetorder(1)
                If !(Dbseek(xFilial('SC5') + alltrim(alinha[nPosPed])))
                    //cMsg += aAux[i] + chr(10)+ chr(13)
                    cPedidos += +"'"+aLinha[nPosPed]+"' ,"

                    if len(alinha) >= 4
                        cQuery := " SELECT C5_NUM,D_E_L_E_T_ FROM "+RetSqlName('SC5')+"(NOLOCK) "
                        cQuery += " WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND C5_ZZIDAPP = '"+ALINHA[4]+"' "
                        cQuery += " AND D_E_L_E_T_ = '' "

                        If Select("XAGORUS") <> 0
                            dbSelectArea("XAGORUS")
                            XAGORUS->(dbCloseArea())
                        Endif
                    
                        TCQuery cQuery NEW ALIAS "XAGORUS"  

                        if  XAGORUS->(!eof())
                            cMsg += aAux[i] + 'NOVO NUMERO DE PEDIDO ('+XAGORUS->C5_NUM+')' + chr(10)+ chr(13) 
                        Else 
                            cMsg += aAux[i] + chr(10)+ chr(13)
                        Endif 
                    else
                        cMsg += aAux[i] + chr(10)+ chr(13)  
                    Endif 
                
                
                Endif
                    
            Next I 

            If cPedidos <> ''
                cMsg +="DELETADOS("

                cQuery := " SELECT C5_NUM,D_E_L_E_T_ FROM "+RetSqlName('SC5')+"(NOLOCK) "
                cQuery += " WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND C5_NUM IN ("+Substr(cPedidos,1,len(cPedidos)-2)+")"
                cQuery += " AND D_E_L_E_T_ = '*' "

                If Select("XAGORUS") <> 0
                    dbSelectArea("XAGORUS")
                    XAGORUS->(dbCloseArea())
                Endif
            
                TCQuery cQuery NEW ALIAS "XAGORUS"  

                While XAGORUS->(!eof())
                    cMsg += XAGORUS->C5_NUM+" , "
                    XAGORUS->(dbskip())
                Enddo
                cMsg +=")"
            Endif 

            
            If cMsg <> ''
                u_msgmemo("PEDIDOS: que nao existem no protheus ",cMsg,.f.)
            Endif   
        
        Else
            nPosVisita := 7
             //Varre TXT
            For I := 1 to len(aAux)
                aLinha := separa(aAux[I],';')

                //Ignora linhas em Branco
                If len(aLinha) == 0 
                    //Alert('Não gerou a linha')
                    loop
                Endif 

                If len(aLinha) < 7 
                    Loop
                Endif 
               /* If alltrim(aLinha[1]) == 'INCLUSAO'
                    nPosPed := 5
                Elseif alltrim(aLinha[1]) == 'CONSULTA'
                loop
                Else
                    nPosPed := 2 
                Endif 
                */  

                cQuery := " SELECT AD7_ZZBLIN,D_E_L_E_T_ AS DEL FROM "+RetSqlName('AD7')+" (NOLOCK) "
                cQuery += " WHERE AD7_FILIAL = '"+xFilial('SC5')+"' "//AND AD7_ZZBLIN = '"+alltrim(aLinha[nPosVisita])+"' "
                cQuery += " AND R_E_C_N_O_ = "+alltrim(aLinha[nPosVisita]) + ""

                If Select("XAGORUS") <> 0
                    dbSelectArea("XAGORUS")
                    XAGORUS->(dbCloseArea())
                Endif
            
                TCQuery cQuery NEW ALIAS "XAGORUS"  

                If XAGORUS->(!Eof())

                    If XAGORUS->(DEL) == '*'
                        cMsg += "(DELETADO NO PROTHEUS) "+aAux[i] + chr(10)+ chr(13)
                    Endif 
                else
                    cMsg += aAux[i] + chr(10)+ chr(13)                   
                Endif 
                //INCLUSAO;07/04/22;17:28:17;20220407141544RL0100;CLIENTE;00254 01

            Next I 

            If cMsg <> ''
                u_msgmemo("VISITAS: que nao existem no protheus ",cMsg,.f.)
            else
                Alert('Nenhuma divergência encontrada')
            Endif   


        Endif 

    Else
        Final("Não foi possivel abrir o arquivo: " + cPath)
    EndIf

  

Return (NIL)

/*SELECT value FROM STRING_SPLIT(substring('Data: 31/03/22 hora: 11:49:07 - pedido: 20220331114652RL0129;925471',LEN('Data: 31/03/22 hora: 11:49:07 - pedido: 20220331114652RL0129;925471')-6,7), ';')
EXCEPT 
SELECT C5_NUM FROM SC5010(NOLOCK)
WHERE C5_EMISSAO >= '20220331'
AND C5_X_ORIG = 'ORUS'
AND C5_NUM IN ('925355','925352','925471')*/
