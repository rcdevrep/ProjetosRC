#INCLUDE "PROTHEUS.CH"
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Data      |     Autor       |       Descrição
 2024/05/23   | Filipe Oliveira |  Ponto de entrada para montagem do Header dos Grids  
 2024/05/27   | Jader Berto     |  Otimização para atribuir valor de bloqueio ao campo RA_MAT                                
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
User function GP180HEA()
    Local aHeader1 := PARAMIXB[1]
    Local aHeader2 := PARAMIXB[2]

    AHEADER1[6][14] := "V"
    
Return {aHeader1,aHeader2}

