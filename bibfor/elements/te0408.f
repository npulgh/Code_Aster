      SUBROUTINE TE0408(OPTION,NOMTE)
      IMPLICIT  NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE

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
C     CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ITABP(8),ITEMPP,INO,NBCOU,NPGH,ITEMPS,IBID
      INTEGER NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO,ISP
      INTEGER IER,IGAUH,ICOU,JNBSPI,IRET,ITEMPF,JRESU,ICACOQ
      REAL*8 TPINF,TPMOY,TPSUP,CP1,CP2,CP3,TPC,ZIC,ZMIN
      REAL*8 INST,DISTN,VALPU(2),HIC,H,R8VIDE
      LOGICAL TEMPNO,GRILLE,LTEATT
      CHARACTER*8 NOMPU(2),ALIAS8

      CALL TEATTR(' ','S','ALIAS8',ALIAS8,IBID)
      GRILLE= LTEATT(' ','GRILLE','OUI')

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO)
      CALL JEVECH('PTEMPCR','E',JRESU)
C      CALL JEVECH('PNBSP_I','L',JNBSPI)
C     NBCOU : NOMBRE DE COUCHES
      CALL TECACH('NNN','PNBSP_I',1,JNBSPI,IRET)
      IF (IRET.EQ.0) THEN
        NBCOU = ZI(JNBSPI-1+1)
      ELSE
C       CAS DES GRILLES
        NBCOU = 1
      ENDIF
      CALL JEVECH('PCACOQU','L',ICACOQ)
      H = ZR(ICACOQ)
      HIC = H/NBCOU


C     1- SI LA TEMPERATURE EST AUX NOEUDS (TEMP/TEMP_SUP/TEMP_INF):
C        ------------------------------------------------------------
      CALL TECACH('ONN','PTEMPER',8,ITABP,IRET)
      IF (IRET.EQ.0 .OR. IRET.EQ.3) THEN
        TEMPNO = .TRUE.
        ITEMPP = ITABP(1)
C       -- CALCUL DES TEMPERATURES INF, SUP ET MOY
C          (MOYENNE DES NNO NOEUDS) ET DES COEF. DES POLY. DE DEGRE 2 :
C          ------------------------------------------------------------
        TPINF = 0.D0
        TPMOY = 0.D0
        TPSUP = 0.D0
        DO 10,INO = 1,NNO
          CALL DXTPIF(ZR(ITEMPP+3* (INO-1)),ZL(ITABP(8)+3* (INO-1)))
          TPMOY = TPMOY + ZR(ITEMPP-1+3* (INO-1)+1)/DBLE(NNO)
          TPINF = TPINF + ZR(ITEMPP-1+3* (INO-1)+2)/DBLE(NNO)
          TPSUP = TPSUP + ZR(ITEMPP-1+3* (INO-1)+3)/DBLE(NNO)
   10   CONTINUE
        CP1 = TPMOY
        CP2 = (TPSUP-TPINF)/H
        CP3 = 2.D0* (TPINF+TPSUP-2.D0*TPMOY)/ (H*H)


      ELSE
C     2- SI LA TEMPERATURE EST UNE FONCTION DE 'INST' ET 'EPAIS'
C        -------------------------------------------------------
        CALL TECACH('ONN','PTEMPEF',1,ITEMPF,IRET)
        CALL ASSERT(IRET.EQ.0)
        CALL JEVECH('PINST_R','E',ITEMPS)
        INST = ZR(ITEMPS)
        TEMPNO = .FALSE.
        NOMPU(1) = 'INST'
        NOMPU(2) = 'EPAIS'
      ENDIF


C     -- CALCUL DE LA TEMPERATURE SUR LES COUCHES :
C     ----------------------------------------------
C     NPGH  : NOMBRE DE POINTS PAR COUCHE
      IF (GRILLE) THEN
        NPGH = 1
        CALL ASSERT(NBCOU.EQ.1)
      ELSE
        NPGH = 3
      ENDIF

C     LA TEMPERATURE EST CONNUE SUR LA COQUE EVENTUELLEMENT EXCENTREE
C     MAIS LA GRILLE PEUT ETRE DECALEE VIS-A-VIS DE LA COQUE
C     SOUS-JACENTE (DIST_N) :
      DISTN=R8VIDE()
      IF (GRILLE)  DISTN = ZR(ICACOQ-1+4)

      IF (GRILLE) THEN
        ZMIN = -H/2.D0 + DISTN
      ELSE
        ZMIN = -H/2.D0
      ENDIF


      DO 30,ICOU = 1,NBCOU
        DO 20,IGAUH = 1,NPGH
          ISP = (ICOU-1)*NPGH + IGAUH

          IF (IGAUH.EQ.1) THEN
            IF (GRILLE) THEN
              ZIC = ZMIN + HIC/2.D0
            ELSE
              ZIC = ZMIN + (ICOU-1)*HIC
            ENDIF
          ELSEIF (IGAUH.EQ.2) THEN
            ZIC = ZMIN + HIC/2.D0 + (ICOU-1)*HIC
          ELSE
            ZIC = ZMIN + HIC + (ICOU-1)*HIC
          ENDIF

          IF (TEMPNO) THEN
            TPC = CP3*ZIC*ZIC + CP2*ZIC + CP1
          ELSE
            VALPU(2) = ZIC
            VALPU(1) = INST
            CALL FOINTE('FM',ZK8(ITEMPF),2,NOMPU,VALPU,TPC,IER)
          ENDIF

          ZR(JRESU-1+ISP) = TPC
   20   CONTINUE
   30 CONTINUE

      END
