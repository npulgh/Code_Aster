      SUBROUTINE TE0463 ( OPTION , NOMTE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/09/2012   AUTEUR PELLET J.PELLET 
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
      CHARACTER*16        OPTION , NOMTE
C ----------------------------------------------------------------------
C     CALCUL DES COORDONNEES DES SOUS POINTS DE GAUSS SUR LES FAMILLE
C     DE LA LISTE MATER
C     POUR LES ELEMENTS : POU_D_EM ET POU_D_TGM
C ----------------------------------------------------------------------
C     NOMBRE MAX DE FAMILLE DANS MATER
      INTEGER NFPGMX
C     NOMBRE MAX DE POINTS DE GAUSS
      INTEGER NBPGMX
      PARAMETER (NFPGMX=10,NBPGMX=3)

      INTEGER  NDIM,NNO,NNOS,NPG,JGANO,ICOPG,IDFDE,IPOIDS,IVF,IGEOM
      INTEGER  NDIM1,IGEPO
      INTEGER  INBF,NBFIB,JACF,IORIEN
      INTEGER  NCARFI,NFPG
      INTEGER  IFPG,NPGFA(NFPGMX)
      INTEGER  IG,IFI,DECGA,K,DECFPG(NFPGMX)
      REAL*8   COPG(4,4),COPGFA(3,NBPGMX,NFPGMX),PGL(3,3),GM1(3),GM2(3)
      CHARACTER*8 FAMI(NFPGMX)

C ----------------------------------------------------------------------

      IF((NOMTE.NE.'MECA_POU_D_EM')
     &           .AND.(NOMTE.NE.'MECA_POU_D_TGM')) THEN
        CALL ASSERT(.FALSE.)
      ENDIF

      CALL JEVECH('PGEOMER','L',IGEOM)
      NDIM  = 3

C     ZR(ICOPG) : COORDONNEES DE SOUS-POINTS DE GAUSS
      CALL JEVECH('PCOOPGM','E',ICOPG )

C ELEMENTS A SOUS POINTS : POUTRES MULTIFIBRES

      CALL JEVECH('PNBSP_I','L',INBF)
      NBFIB = ZI(INBF)
      CALL JEVECH('PFIBRES','L',JACF)
      NCARFI = 3
      CALL JEVECH('PCAORIE','L',IORIEN)
      CALL MATROT(ZR(IORIEN),PGL)
      DECGA=NBFIB*NDIM

      CALL FMATER(NFPGMX,NFPG,FAMI)
      DECFPG(1)=0
      DO 200 IFPG=1,NFPG

        CALL ELREF4(' ',FAMI(IFPG),NDIM1,NNO,NNOS,NPG,IPOIDS,IVF,
     &                                               IDFDE,JGANO)
        IF (IFPG.LT.NFPG) DECFPG(IFPG+1)=DECFPG(IFPG)+NPG

C       POSITION DES POINTS DE GAUSS SUR L'AXE POUR FAMI
        CALL PPGA12(NDIM,NNO,NPG,ZR(IPOIDS),ZR(IVF),
     &              ZR(IGEOM),COPG)
        NPGFA(IFPG) = NPG
        DO 10 IG=1,NPG
          DO 20 K=1,NDIM
            COPGFA(K,IG,IFPG)=COPG(K,IG)
 20       CONTINUE
 10     CONTINUE

 200  CONTINUE


      GM1(1)=0.D0

      DO 100 IFI=1,NBFIB
        GM1(2)=ZR(JACF+(IFI-1)*NCARFI)
        GM1(3)=ZR(JACF+(IFI-1)*NCARFI+1)
        CALL UTPVLG(1,3,PGL,GM1,GM2)
        DO 120 IFPG=1,NFPG
          DO 110 IG=1,NPGFA(IFPG)

            ZR(ICOPG+(DECFPG(IFPG)+IG-1)*DECGA+(IFI-1)*NDIM+0)
     &                               =COPGFA(1,IG,IFPG)+GM2(1)
            ZR(ICOPG+(DECFPG(IFPG)+IG-1)*DECGA+(IFI-1)*NDIM+1)
     &                               =COPGFA(2,IG,IFPG)+GM2(2)
            ZR(ICOPG+(DECFPG(IFPG)+IG-1)*DECGA+(IFI-1)*NDIM+2)
     &                               =COPGFA(3,IG,IFPG)+GM2(3)
 110      CONTINUE
 120    CONTINUE
 100  CONTINUE




      END
