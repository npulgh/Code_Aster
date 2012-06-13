      SUBROUTINE TE0563(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16       NOMTE,OPTION
C.----------------------------------------------------------------------
C     OPTION : NORME
C     
C     BUT: CALCUL LA NORME L2 AU CARRE
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.----------------------------------------------------------------------
C

      INTEGER IPOIDS,ICHAM,INORM,NBV,NCMP1,NCMP2,NPG,I,J,IRET,NCMP3
      INTEGER NDIM,NNO,NNOS,IVF,IDFDX,JGANO,JTAB1(2),JTAB2(2),ICOEF
      INTEGER JTAB3(2),IBID
      REAL*8 RESU,VALE,POIDS
      CHARACTER*8 K8B

      COMMON /NOMAJE/PGC
      CHARACTER*6 PGC
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IBID,IVF,IDFDX,JGANO)
C
      CALL JEVECH('PCOORPG','L',IPOIDS)
      CALL JEVECH('PCHAMPG','L',ICHAM)
      CALL JEVECH('PCOEFR','L',ICOEF)
      CALL JEVECH('PNORME','E',INORM)
C     
      CALL TECACH('OON','PCHAMPG',2,JTAB1,IRET)
C     NOMBRE DE COMPOSANTES DU CHAMP DE VALEURS (=30) : NCMP1
      NCMP1=JTAB1(2)/NPG

      CALL TECACH('OON','PCOORPG',2,JTAB2,IRET)
C     NOMBRE DE COMPOSANTES DU CHAMP COOR_ELGA (3 OU 4) : NCMP2
      NCMP2=JTAB2(2)/NPG

      CALL TECACH('OON','PCOEFR',2,JTAB3,IRET)
C     NOMBRE DE COMPOSANTES DU CHAMP DE COEF (=30) : NCMP3
      NCMP3=JTAB3(2)
      CALL ASSERT(NCMP3.EQ.NCMP1)

      RESU=0.D0
      DO 10 I=1,NPG
         POIDS=ZR(IPOIDS+NCMP2*(I-1)+NCMP2-1)
         VALE=0.D0
         DO 20 J=1,NCMP1
           VALE = VALE + ZR(ICOEF+J-1) *
     &            ZR(ICHAM+NCMP1*(I-1)+J-1)*ZR(ICHAM+NCMP1*(I-1)+J-1)
 20      CONTINUE
         RESU=RESU+VALE*POIDS
 10   CONTINUE

      ZR(INORM)=RESU

      END
