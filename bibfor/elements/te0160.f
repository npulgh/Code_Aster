      SUBROUTINE TE0160(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C INTRODUCTION DE LA TEMPERATURE
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - ELEMENT:  MECABL2
C      OPTION : 'FULL_MECA'   'RAPH_MECA'   'RIGI_MECA_TANG'

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 NOMRES(2)
      INTEGER ICODRE(2)
      REAL*8 A,BILINE,COEF,COEF1,COEF2,DEMI
      REAL*8 VALRES(2),E,EPSTH
      REAL*8 GREEN,JACOBI,NX,YTYWPQ(9),W(9)
      INTEGER NNO,KP,I,J,IMATUU,IRET
      INTEGER IPOIDS,IVF,IGEOM,IMATE,JCRET


      DEMI = 0.5D0


      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDK,JGANO)
      CALL JEVETE('&INEL.CABPOU.YTY','L',IYTY)

      NORDRE = 3*NNO

C PARAMETRES EN ENTREE
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_INCR') THEN
        CALL U2MESS('F','ELEMENTS3_36')
      END IF
      IF (ZK16(ICOMPO) (1:5).NE.'CABLE') THEN
        CALL U2MESK('F','ELEMENTS3_37',1,ZK16(ICOMPO))
      END IF
      IF (ZK16(ICOMPO+1).NE.'GROT_GDEP') THEN
        CALL U2MESK('F','ELEMENTS3_38',1,ZK16(ICOMPO+1))
      END IF
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      NOMRES(1) = 'E'
      NOMRES(2) = 'EC_SUR_E'
      CALL RCVALB('RIGI',1,1,'+',ZI(IMATE),' ','ELAS',
     &           0,'  ',R8BID,1,NOMRES,VALRES,
     &           ICODRE, 1)
      CALL RCVALB('RIGI',1,1,'+',ZI(IMATE),' ','CABLE',
     &            0,'  ',R8BID,1,NOMRES(2),
     &            VALRES(2),ICODRE(2), 1)
      E = VALRES(1)
      EC = E*VALRES(2)
      CALL JEVECH('PCACABL','L',LSECT)
      A = ZR(LSECT)
      PRETEN = ZR(LSECT+1)
      CALL JEVECH('PDEPLMR','L',IDEPLA)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
C PARAMETRES EN SORTIE
      IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &    OPTION(1:14).EQ.'RIGI_MECA_TANG') THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
      END IF
      IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &    OPTION(1:9).EQ.'RAPH_MECA') THEN
        CALL JEVECH('PVECTUR','E',JEFINT)
        CALL JEVECH('PCONTPR','E',LSIGMA)
      END IF

      DO 20 I = 1,3*NNO
        W(I) = ZR(IDEPLA-1+I) + ZR(IDEPLP-1+I)
   20 CONTINUE

      DO 70 KP = 1,NPG

        CALL VERIFT('RIGI',KP,1,'+',ZI(IMATE),'ELAS',1,EPSTH,IRET)

        K = (KP-1)*NORDRE*NORDRE
        JACOBI = SQRT(BILINE(NORDRE,ZR(IGEOM),ZR(IYTY+K),ZR(IGEOM)))

        GREEN = (BILINE(NORDRE,W,ZR(IYTY+K),ZR(IGEOM))+
     &          DEMI*BILINE(NORDRE,W,ZR(IYTY+K),W))/JACOBI**2

        NX = E*A*GREEN
        IF (ABS(NX).LT.1.D-6) THEN
          NX = PRETEN
        ELSE
          NX = NX - E*A*EPSTH
        END IF

C*** LE CABLE A UN MODULE BEAUCOUP PLUS FAIBLE A LA COMPRESSION QU'A LA
C*** TRACTION. LE MODULE DE COMPRESSION PEUT MEME ETRE NUL.

        IF (NX.LT.0.D0) THEN
          NX = NX*EC/E
          E = EC
        END IF

        COEF1 = E*A*ZR(IPOIDS-1+KP)/JACOBI**3
        COEF2 = NX*ZR(IPOIDS-1+KP)/JACOBI
        CALL MATVEC(NORDRE,ZR(IYTY+K),2,ZR(IGEOM),W,YTYWPQ)
        IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &      OPTION(1:14).EQ.'RIGI_MECA_TANG') THEN
          NELYTY = IYTY - 1 - NORDRE + K
          IMAT = IMATUU - 1
          DO 50 I = 1,NORDRE
            NELYTY = NELYTY + NORDRE

            DO 40 J = 1,I
              IMAT = IMAT + 1
              ZR(IMAT) = ZR(IMAT) + COEF1*YTYWPQ(I)*YTYWPQ(J) +
     &                   COEF2*ZR(NELYTY+J)
   40       CONTINUE
   50     CONTINUE
        END IF
        IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &      OPTION(1:9).EQ.'RAPH_MECA') THEN
          COEF = NX*ZR(IPOIDS-1+KP)/JACOBI
          DO 60 I = 1,NORDRE
            ZR(JEFINT-1+I) = ZR(JEFINT-1+I) + COEF*YTYWPQ(I)
   60     CONTINUE
          ZR(LSIGMA-1+KP) = NX
        END IF
   70 CONTINUE

      IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &    OPTION(1:9).EQ.'RAPH_MECA') THEN
        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = 0
      END IF

      END
