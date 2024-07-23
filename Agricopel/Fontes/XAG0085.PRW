#include "rwmake.ch"
#include "protheus.ch"

/*
/---------------------------------------------------------------------
|RdMake XAG0085| Autor | Osmar Schimitberger | Data 01/04/2022       |
|---------------------------------------------------------------------
|              | FONTE PARA TRATAR FUNCOES CNAB B.BRASIL             |
|Descricao     | CNAB MOD II 240 POSICOES - BRASIL.2PE               |
|              | POSICOES 111 A 230                                  |
|---------------------------------------------------------------------
|Sintaxe       | U_XAG0085()                                         | 
|---------------------------------------------------------------------
|Uso           | Agricopel                                           | 
|---------------------------------------------------------------------
*/

//Tratamento N1.GPS - N2.DARF - N3.DARF SIMPLES - W1.FGTS
User Function XAG0085()

Local cTributo:= ""
Local cPeriodo:= GRAVADATA(SE2->E2_DTAPUR,.F.,5)
Local cMesAno:= strzero(Month(SE2->E2_DTAPUR),2)+strzero(year(SE2->E2_DTAPUR),4)                                

          //COD.RECEITA   TIPO CONTRIB  IDENT.CONTRIB             COD.ID.TRIBUTO    MES/ANO COMP                    VLR INSS                       VLR OUT.ENTIDADES           ATU.MONETARIA    USO FEBRABAN
//N1.GPS   111 A 116     /  117 A 118	 / 119 A 132   /             133 A 134  /    135 A 140  /                   141 A 155                    /    156 A 170               /  171 A 185    /  186 A 230

If !Empty(SE2->E2_RETINS) .and. SEA->EA_MODELO $"17" //2208
	//cTributo:= +"00"+SE2->E2_RETINS+"01"+STRZERO(VAL(SM0->M0_CGC),14)+"17"     +    cMesAno+STRZERO(((SE2->E2_SALDO-SE2->E2_PRINSS)*100),15)+STRZERO((SE2->E2_PRINSS*100),15) +STRZERO(0,15)    +SPACE(45)
	cTributo:= +"00"+SE2->E2_RETINS+IIF(ALLTRIM(SE2->E2_RETINS)=="2208","04","01")+IIF(ALLTRIM(SE2->E2_RETINS)=="2208","00700142976678",STRZERO(VAL(SM0->M0_CGC),14))+"17"     +    cMesAno+STRZERO(((SE2->E2_SALDO-SE2->E2_PRINSS)*100),15)+STRZERO((SE2->E2_PRINSS*100),15) +STRZERO(0,15)    +SPACE(45)
Endif

            //COD.RECEITA   TIPO CONTRIB  IDENT.CONTRIB           COD.ID.TRIBUTO    PERIODO APUR.   NR.REFERENCIA                   VLR PRINCIPAL                          VLR MULTA                 VLR JUROS/ENC.                  DATA VENCTO               USO FEBRABAN
//N2.DARF    111 A 116     /  117 A 118	 / 119 A 132   /              133 A 134  /    135 A 142  /    143 A 159                    /    160 A 174          /               175 A 189                 /  190 A 204                    /   205 A 212              /  213 A 230

If !Empty(SE2->E2_CODRET)  .and. SEA->EA_MODELO $"16"
	cTributo:= "00"+SE2->E2_CODRET+"01"+STRZERO(VAL(SM0->M0_CGC),14)+"16"     +    cPeriodo+STRZERO((SE2->E2_SALDO*100),17)+STRZERO((SE2->E2_VALOR*100),15) + STRZERO((SE2->E2_MULTA*100),15) +STRZERO((SE2->E2_VALJUR*100),15)+GRAVADATA(SE2->E2_VENCREA,.F.,5) +SPACE(18)
Endif

                   //COD.RECEITA   TIPO CONTRIB  IDENT.CONTRIB    COD.ID.TRIBUTO    PERIODO APUR.   VLR.REC.BRUTA             ACUM  PERC.S/BRUTA BRUTA    VALOR PRINCIPAL                      VLR MULTA                    VLR JUROS/ENC.             USO FEBRABAN
//N3. DARF Simples   111 A 116  /  117 A 118	 / 119 A 132   /     133 A 134  /    135 A 142  /      143 A 157                 /158 A 164              /   165 A 179                        /  180 A 194                  /  195 A 209                 / 210 A 230

If !Empty(SE2->E2_CODRET).and. SEA->EA_MODELO $"18"
	cTributo:= "00"+SE2->E2_CODRET+"01"+STRZERO(VAL(SM0->M0_CGC),14)+"18"     +    cPeriodo+STRZERO((SE2->E2_VALOR*100),15)+STRZERO(100*100,7) + STRZERO((SE2->E2_VALOR*100),15) + STRZERO((SE2->E2_MULTA*100),15) + STRZERO((SE2->E2_VALJUR*100),15) + SPACE(21)
Endif           

                   //COD.RECEITA   TIPO CONTRIB  IDENT.CONTRIB           COD.ID.FTGS    LACRE CONECT.SOCIAL  DIG.LACRE CONECT.SOCIAL    USO FEBRABAN
//W1.INF COMPL FGTS  179 A 184  /  185 A 186	 / 187 A 200   /          201 A 216  /    217 A 225  /          226 A 227           /  228 A 228  

If SEA->EA_MODELO $"13" //FGTS
    cTributo:= "115"+space(3)+       "01"+STRZERO(VAL(SM0->M0_CGC),14)+space(16)        +space(9)             +space(2)              +space(1)
Endif

Return(cTributo)
