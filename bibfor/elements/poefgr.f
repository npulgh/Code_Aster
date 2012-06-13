      SUBROUTINE POEFGR(NOMTE,KLC,MATER,E,XNU,RHO,EFFO)
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      CHARACTER*(*) NOMTE
      REAL*8 KLC(12,12),E,XNU,RHO,EFFO(*)
C TOLE CRP_6
C     ------------------------------------------------------------------
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

C     CALCUL DU VECTEUR ELEMENTAIRE EFFORT GENERALISE REEL,
C     POUR LES ELEMENTS DE POUTRE D'EULER ET DE TIMOSHENKO.
C     ------------------------------------------------------------------

      REAL*8 UL(12),FE(12),MLV(78),MLC(12,12),FEI(12)
      REAL*8 PGL(3,3),PGL1(3,3),PGL2(3,3)
      CHARACTER*24 SUROPT
      REAL*8 TRIGOM
C     ------------------------------------------------------------------

      ZERO = 0.D0
      DEUX = 2.D0
      NNO = 2
      NC = 6
      NNOC = 1
      NCC = 6
C     ------------------------------------------------------------------

C     --- RECUPERATION DES CARACTERISTIQUES GENERALES DES SECTIONS ---

      CALL JEVECH('PCAGNPO','L',LSECT)
      LSECT = LSECT - 1
      LSECT2 = LSECT + 11
      ITYPE = NINT(ZR(LSECT+23))
      A = ZR(LSECT+1)
      A2 = ZR(LSECT2+1)

C     --- RECUPERATION DES COORDONNEES DES NOEUDS ---
      CALL JEVECH('PGEOMER','L',LX)
      LX = LX - 1
      XL = SQRT((ZR(LX+4)-ZR(LX+1))**2+ (ZR(LX+5)-ZR(LX+2))**2+
     &     (ZR(LX+6)-ZR(LX+3))**2)
      IF (ITYPE.EQ.10) THEN
        CALL JEVECH('PCAARPO','L',LRCOU)
        RAD = ZR(LRCOU)
        ANGARC = ZR(LRCOU+1)
        ANGS2 = TRIGOM('ASIN',XL/ (DEUX*RAD))
        XL = RAD*ANGS2*DEUX
      END IF

C     --- MATRICE DE ROTATION PGL

      CALL JEVECH('PCAORIE','L',LORIEN)
      IF (ITYPE.EQ.10) THEN
        CALL MATRO2(ZR(LORIEN),ANGARC,ANGS2,PGL1,PGL2)
      ELSE
        CALL MATROT(ZR(LORIEN),PGL)
      END IF

C      --- VECTEUR DEPLACEMENT LOCAL ---

      CALL JEVECH('PDEPLAR','L',JDEPL)
      IF (ITYPE.EQ.10) THEN
        CALL UTPVGL(NNOC,NCC,PGL1,ZR(JDEPL),UL)
        CALL UTPVGL(NNOC,NCC,PGL2,ZR(JDEPL+6),UL(7))
      ELSE
        CALL UTPVGL(NNO,NC,PGL,ZR(JDEPL),UL)
      END IF

C     --- VECTEUR EFFORT LOCAL  EFFO = KLC * UL

      CALL PMAVEC('ZERO',12,KLC,UL,EFFO)

C     --- TENIR COMPTE DES EFFORTS DUS A LA DILATATION ---

      CALL VERIFM('NOEU',NNO,1,'+',MATER,'ELAS',1,F,IRET)

      IF (F.NE.ZERO) THEN
          DO 10 I = 1,12
            UL(I) = ZERO
   10     CONTINUE

          IF (ITYPE.NE.10) THEN
            UL(1) = -F*XL
            UL(7) = -UL(1)
          ELSE
            ALONG = DEUX*RAD*F*SIN(ANGS2)
            UL(1) = -ALONG*COS(ANGS2)
            UL(2) = ALONG*SIN(ANGS2)
            UL(7) = -UL(1)
            UL(8) = UL(2)
          END IF
C              --- CALCUL DES FORCES INDUITES ---
          DO 30 I = 1,6
            DO 20 J = 1,6
              EFFO(I) = EFFO(I) - KLC(I,J)*UL(J)
              EFFO(I+6) = EFFO(I+6) - KLC(I+6,J+6)*UL(J+6)
   20       CONTINUE
   30     CONTINUE
      ENDIF

C     --- TENIR COMPTE DES EFFORTS REPARTIS/PESANTEUR ---

      CALL PTFORP(ITYPE,'CHAR_MECA_PESA_R',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FE,FEI)
      DO 40 I = 1,12
        EFFO(I) = EFFO(I) - FE(I)
   40 CONTINUE

      CALL PTFORP(ITYPE,'CHAR_MECA_FR1D1D',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FE,FEI)
      DO 50 I = 1,12
        EFFO(I) = EFFO(I) - FE(I)
   50 CONTINUE

      CALL PTFORP(ITYPE,'CHAR_MECA_FF1D1D',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FE,FEI)
      DO 60 I = 1,12
        EFFO(I) = EFFO(I) - FE(I)
   60 CONTINUE

C      --- FORCE DYNAMIQUE ---

C      IF ( RHO .NE. ZERO ) THEN
      KANL = 2
      CALL JEVECH('PSUROPT','L',LOPT)
      SUROPT = ZK24(LOPT)
      IF (SUROPT(1:4).EQ.'MASS') THEN
        IF (SUROPT.EQ.'MASS_MECA_DIAG' .OR.
     &      SUROPT.EQ.'MASS_MECA_EXPLI' ) KANL = 0
        IF (SUROPT.EQ.'MASS_MECA     ') KANL = 1
        IF (SUROPT.EQ.'MASS_FLUI_STRU') KANL = 1
        IF (KANL.EQ.2) THEN
          CALL U2MESK('A','ELEMENTS2_44',1,SUROPT)
        END IF
        IF (NOMTE(1:13).EQ.'MECA_POU_D_EM') THEN
          CALL JEVECH ( 'PMATERC', 'L', LMATER )
          CALL PMFMAS(NOMTE,ZI(LMATER),KANL,MLV)
        ELSE
          CALL POMASS(NOMTE,E,XNU,RHO,KANL,MLV)
        ENDIF
        CALL VECMA(MLV,78,MLC,12)
        CALL JEVECH('PCHDYNR','L',LDYNA)
        IF (ITYPE.EQ.10) THEN
          CALL UTPVGL(NNOC,NCC,PGL1,ZR(LDYNA),UL)
          CALL UTPVGL(NNOC,NCC,PGL2,ZR(LDYNA+6),UL(7))
        ELSE
          CALL UTPVGL(NNO,NC,PGL,ZR(LDYNA),UL)
        END IF
        CALL PMAVEC('ZERO',12,MLC,UL,FE)
        DO 70 I = 1,12
          EFFO(I) = EFFO(I) + FE(I)
   70   CONTINUE
      END IF

      END
