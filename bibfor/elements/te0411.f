      SUBROUTINE TE0411(OPTION,NOMTE)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C
C                 CALCUL DE ROSETTE, OPTION : SIRO_ELEM
C
C IN   OPTION    : OPTION DE CALCUL
C IN   NOMTE     : NOM DU TYPE ELEMENT
C
C ----------------------------------------------------------------------
      INTEGER  ISIG,NNOP,NDIM,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO,I
      INTEGER  IGEOM,J,IFONC,INO,IADZI,IAZK24,ISIGM,IAUX1,IAUX2

      REAL*8   PREC,NORT1,NORT2,NORNO,L1,L2,DELTA
      REAL*8   VTAN1(3),VTAN2(3),VT1(3),VT2(3),VNO(3)
      REAL*8   V1(3),V2(3),VTMP(3),VTMP2(3)
      REAL*8   SIGG(3,3),MLG(3,3),MTMP(3,3),SIGL(3,3),MGL(3,3),DET
      REAL*8   DFF(162),X1

      CHARACTER*8 ELREFE
      PARAMETER(PREC=1.0D-10)
C ----------------------------------------------------------------------
      CALL JEMARQ()
C
      CALL TECAEL(IADZI,IAZK24)
      CALL ELREF1(ELREFE)
      CALL ELREF4(' ','RIGI',NDIM,NNOP,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PSIG3D' ,'L',ISIG)
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PPJSIGM','E',ISIGM)
C
C     CALCUL DES DERIVEES DES FONCTIONS DE FORMES AUX NOEUDS DE L'ELREFE
      CALL DFFNO ( ELREFE, NDIM, NNOP, NNOS, DFF )
C
C --- ------------------------------------------------------------------
C --- CALCUL DU REPERE LOCAL : (VT1, VT2, VNO)
C        VT1, VT2 = VECTEURS TANGENTS A L'ELEMENT
C        VNO = VECTEUR NORMAL A L'ELEMENT

C     INITIALISATION
      DO 9 I=1,3
         VT1(I) = 0.D0
         VT2(I) = 0.D0
         VNO(I) = 0.D0
         DO 8 J=I,3
            SIGG(I,J)=0.D0
 8       CONTINUE
 9    CONTINUE
C
C --- ------------------------------------------------------------------
C --- BOUCLE SUR LES NOEUDS DE L'ELEMENT
      DO 10 INO=1,NNOP
C
         DO 12 I=1,3
            VTAN1(I) = 0.D0
            VTAN2(I) = 0.D0
 12      CONTINUE
C
         DO 20 IFONC=1,NNOP
            IAUX1 = IGEOM-1+3*(IFONC-1)
            IAUX2 = (INO-1)*NNOP*2 + IFONC
            VTAN1(1) = VTAN1(1) + ZR(IAUX1+1)*DFF(IAUX2)
            VTAN1(2) = VTAN1(2) + ZR(IAUX1+2)*DFF(IAUX2)
            VTAN1(3) = VTAN1(3) + ZR(IAUX1+3)*DFF(IAUX2)
            VTAN2(1) = VTAN2(1) + ZR(IAUX1+1)*DFF(IAUX2+NNOP)
            VTAN2(2) = VTAN2(2) + ZR(IAUX1+2)*DFF(IAUX2+NNOP)
            VTAN2(3) = VTAN2(3) + ZR(IAUX1+3)*DFF(IAUX2+NNOP)
 20      CONTINUE
C
         VT1(1)=VT1(1)+VTAN1(1)
         VT1(2)=VT1(2)+VTAN1(2)
         VT1(3)=VT1(3)+VTAN1(3)
         VT2(1)=VT2(1)+VTAN2(1)
         VT2(2)=VT2(2)+VTAN2(2)
         VT2(3)=VT2(3)+VTAN2(3)
C
         SIGG(1,1)=SIGG(1,1)+ZR(ISIG+6*(INO-1))
         SIGG(2,2)=SIGG(2,2)+ZR(ISIG+6*(INO-1)+1)
         SIGG(3,3)=SIGG(3,3)+ZR(ISIG+6*(INO-1)+2)
         SIGG(1,2)=SIGG(1,2)+ZR(ISIG+6*(INO-1)+3)
         SIGG(1,3)=SIGG(1,3)+ZR(ISIG+6*(INO-1)+4)
         SIGG(2,3)=SIGG(2,3)+ZR(ISIG+6*(INO-1)+5)
C
 10   CONTINUE
C --- ------------------------------------------------------------------
C --- VECTEURS TANGENTS PAR MOYENNE DE CHAQUE COMPOSANTE
      VT1(1)=VT1(1)/NNOP
      VT1(2)=VT1(2)/NNOP
      VT1(3)=VT1(3)/NNOP
      VT2(1)=VT2(1)/NNOP
      VT2(2)=VT2(2)/NNOP
      VT2(3)=VT2(3)/NNOP
C --- ------------------------------------------------------------------
C --- TENSEUR DES CONTRAINTES PAR MOYENNE DE CHAQUE COMPOSANTE
      SIGG(1,1)=SIGG(1,1)/NNOP
      SIGG(2,2)=SIGG(2,2)/NNOP
      SIGG(3,3)=SIGG(3,3)/NNOP
      SIGG(1,2)=SIGG(1,2)/NNOP
      SIGG(1,3)=SIGG(1,3)/NNOP
      SIGG(2,3)=SIGG(2,3)/NNOP
      SIGG(2,1)=  SIGG(1,2)
      SIGG(3,1)=  SIGG(1,3)
      SIGG(3,2)=  SIGG(2,3)
C
      CALL NORMEV(VT1,NORT1)
      CALL NORMEV(VT2,NORT2)
      CALL PROVEC(VT1,VT2,VNO)
      CALL NORMEV(VNO,NORNO)
      CALL PROVEC(VNO,VT1,VT2)
C --- ------------------------------------------------------------------
C --- EXPRESSION DES VECTEURS CONTRAINTES DANS LE REPERE LOCAL :
C        (VT1,VT2,VNO)
C        SIX_L = (SIXT1,SIXT2,SIXNO) DANS (VT1,VT2,VNO)
C        SIY_L = (SIYT1,SIYT2,SIYNO) DANS (VT1,VT2,VNO)
C        SIZ_L = (SIZT1,SIZT2,SIZNO) DANS (VT1,VT2,VNO)
C
      DET=VT1(1)*VT2(2)*VNO(3)+VT2(1)*VNO(2)*VT1(3)+VNO(1)*VT1(2)*VT2(3)
     &   -VNO(1)*VT2(2)*VT1(3)-VT1(1)*VNO(2)*VT2(3)-VT2(1)*VT1(2)*VNO(3)
      CALL ASSERT(ABS(DET).GT.PREC)
C
      MGL(1,1) = VT1(1)
      MGL(2,1) = VT2(1)
      MGL(3,1) = VNO(1)
      MGL(1,2) = VT1(2)
      MGL(2,2) = VT2(2)
      MGL(3,2) = VNO(2)
      MGL(1,3) = VT1(3)
      MGL(2,3) = VT2(3)
      MGL(3,3) = VNO(3)
C
      MLG(1,1) = VT1(1)
      MLG(2,1) = VT1(2)
      MLG(3,1) = VT1(3)
      MLG(1,2) = VT2(1)
      MLG(2,2) = VT2(2)
      MLG(3,2) = VT2(3)
      MLG(1,3) = VNO(1)
      MLG(2,3) = VNO(2)
      MLG(3,3) = VNO(3)
C
      CALL PMAT(3,SIGG,MLG,MTMP)
      CALL PMAT(3,MGL,MTMP,SIGL)
C --- ------------------------------------------------------------------
C --- CALCUL DES OPTIONS : SIRO_ELEM_SIT1 & SIRO_ELEM_SIT2
C        DETERMINATION DES 2 MODES PROPRES TELS QUE SIXT2=SIYT1=0
      DELTA=(SIGL(1,1)+SIGL(2,2))**2 -
     &       4.D0*(SIGL(1,1)*SIGL(2,2)-SIGL(1,2)*SIGL(2,1))
      X1= (SIGL(1,1)+SIGL(2,2))**2
      IF (ABS(DELTA).LE.X1*PREC) DELTA=0.D0
      IF (DELTA.LT.0.D0) THEN
         WRITE(6,*) 'DEBUG DELTA=',DELTA
         WRITE(6,*) 'DEBUG SIGL=',SIGL
      ENDIF
      CALL ASSERT(DELTA.GE.0.D0)
      L1=(SIGL(1,1)+SIGL(2,2)-SQRT(DELTA))/2
      L2=(SIGL(1,1)+SIGL(2,2)+SQRT(DELTA))/2
      IF(ABS(SIGL(1,1)-L1).LT.PREC)THEN
         V1(1)=-(SIGL(2,2)-L1)
         V1(2)=SIGL(2,1)
         V1(3)=0.D0
      ELSE
         V1(1)=-SIGL(1,2)
         V1(2)=SIGL(1,1)-L1
         V1(3)=0.D0
      ENDIF
      IF(ABS(SIGL(1,1)-L2).LT.PREC)THEN
         V2(1)=-(SIGL(2,2)-L2)
         V2(2)=SIGL(2,1)
         V2(3)=0.D0
      ELSE
         V2(1)=-SIGL(1,2)
         V2(2)=SIGL(1,1)-L2
         V2(3)=0.D0
      ENDIF
      CALL NORMEV(V1,NORT1)
      CALL PSCVEC(3,L1,V1,V1)
      CALL NORMEV(V2,NORT2)
      CALL PSCVEC(3,L2,V2,V2)
C
      CALL PMAVEC('ZERO',3,MLG,V1,VTMP)
      ZR(ISIGM-1+8) = VTMP(1)
      ZR(ISIGM-1+9) = VTMP(2)
      ZR(ISIGM-1+10)= VTMP(3)
      ZR(ISIGM-1+11)= L1
C
      CALL PMAVEC('ZERO',3,MLG,V2,VTMP)
      ZR(ISIGM-1+12)= VTMP(1)
      ZR(ISIGM-1+13)= VTMP(2)
      ZR(ISIGM-1+14)= VTMP(3)
      ZR(ISIGM-1+15)= L2
C --- ------------------------------------------------------------------
C --- CALCUL DES OPTIONS : SIRO_ELEM_SIGN & SIRO_ELEM_SIGT
      VTMP(1)=0.D0
      VTMP(2)=0.D0
      VTMP(3)=SIGL(3,3)
      CALL PMAVEC('ZERO',3,MLG,VTMP,VTMP2)
      ZR(ISIGM-1+1)= VTMP2(1)
      ZR(ISIGM-1+2)= VTMP2(2)
      ZR(ISIGM-1+3)= VTMP2(3)
      ZR(ISIGM-1+4)= SIGL(3,3)
C
      VTMP(1)=SIGL(3,1)
      VTMP(2)=SIGL(3,2)
      VTMP(3)=0.D0
C
      CALL PMAVEC('ZERO',3,MLG,VTMP,VTMP2)
      ZR(ISIGM-1+5)= VTMP2(1)
      ZR(ISIGM-1+6)= VTMP2(2)
      ZR(ISIGM-1+7)= VTMP2(3)
C
      CALL JEDEMA()
C
      END
