      SUBROUTINE TE0067 (OPTION,NOMTE)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16      OPTION,NOMTE
C ......................................................................
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C    - FONCTION REALISEE:  CALCUL DE Z EN 2D ET AXI
C                          CHGT DE PHASE METALURGIQUE
C                          OPTION : 'META_ELGA_TEMP  ' 'META_ELNO'
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................



      CHARACTER*16   COMPOR(3)
      INTEGER    ICODRE
      REAL*8          DT10,DT21,INSTP
      REAL*8          TNO1,TNO0,TNO2
      REAL*8          METAAC(63),METAZI(36)
      INTEGER        JGANO,NNO,KN,I,ITEMPE,ITEMPA,ITEMPS,IADTRC
      INTEGER        IPOIDS,IVF,IMATE,NDIM,NPG
      INTEGER        NBHIST,ITEMPI,NBTRC,IADCKM,NNOS
      INTEGER        IPFTRC,JFTRC,JTRC,IPHASI,IPHASN,ICOMPO
      INTEGER        MATOS,NBCB1,NBCB2,NBLEXP,IADEXP,IDFDE

      CALL JEMARQ()

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPAR','L',ITEMPA)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PTEMPIR','L',ITEMPI)
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      CALL JEVECH('PPHASIN','L',IPHASI)
      CALL JEVECH('PCOMPOR','L',ICOMPO)

      CALL JEVECH ('PPHASNOU','E',IPHASN)

      COMPOR(1)=ZK16(ICOMPO)
      MATOS = ZI(IMATE)

      IF (COMPOR(1).EQ.'ACIER') THEN

        CALL JEVECH ('PFTRC','L',IPFTRC)
        JFTRC = ZI(IPFTRC)
        JTRC  = ZI(IPFTRC+1)

        CALL RCADMA (MATOS,'META_ACIER','TRC',IADTRC,ICODRE,1)

        NBCB1  = NINT(ZR(IADTRC+1))
        NBHIST = NINT(ZR(IADTRC+2))
        NBCB2  = NINT(ZR(IADTRC+1+2+NBCB1*NBHIST))
        NBLEXP = NINT(ZR(IADTRC+1+2+NBCB1*NBHIST+1))
        NBTRC  = NINT(ZR(IADTRC+1+2+NBCB1*NBHIST+2+NBCB2*NBLEXP+1))
        IADEXP = 5 + NBCB1*NBHIST
        IADCKM = 7 + NBCB1*NBHIST + NBCB2*NBLEXP

        DO 10 KN=1,NNO
C         -- ATTENTION: ZACIER MODIFIE PARFOIS DT10 ET DT21 :
          DT10 = ZR(ITEMPS+1)
          DT21 = ZR(ITEMPS+2)

          TNO1 = ZR(ITEMPE+KN-1)
          TNO0 = ZR(ITEMPA+KN-1)
          TNO2 = ZR(ITEMPI+KN-1)
          CALL ZACIER(MATOS,NBHIST,ZR(JFTRC),ZR(JTRC),ZR(IADTRC+3),
     &               ZR(IADTRC+IADEXP),ZR(IADTRC+IADCKM),NBTRC,TNO0,
     &               TNO1,TNO2,DT10,DT21,ZR(IPHASI+7*(KN-1)),
     &               METAAC(1+7*(KN-1)) )

          DO 20 I=1,7
            ZR(IPHASN+7*(KN-1)+I-1) = METAAC(1+7*(KN-1)+I-1)
  20      CONTINUE
  10    CONTINUE

      ELSEIF (COMPOR(1)(1:4).EQ.'ZIRC') THEN

        DT10 = ZR(ITEMPS+1)
        DT21 = ZR(ITEMPS+2)
        INSTP= ZR(ITEMPS)+DT21

        DO 30 KN=1,NNO
          TNO1 = ZR(ITEMPE+KN-1)
          TNO2 = ZR(ITEMPI+KN-1)
          CALL ZEDGAR(MATOS,TNO1,TNO2,INSTP,DT21,
     &                ZR(IPHASI+4*(KN-1)),METAZI(1+4*(KN-1)))

          DO 40 I=1,4
            ZR(IPHASN+4*(KN-1)+I-1) = METAZI(1+4*(KN-1)+I-1)
 40       CONTINUE
 30     CONTINUE

      ENDIF

      CALL JEDEMA()
      END
