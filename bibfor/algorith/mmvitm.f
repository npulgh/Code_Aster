      SUBROUTINE MMVITM(NBDM  ,NDIM  ,NNE   ,NNM   ,FFE   ,
     &                  FFM   ,JVITM ,JACCM ,JVITP ,VITME ,
     &                  VITMM ,VITPE ,VITPM ,ACCME ,ACCMM )
C 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER      NBDM,NDIM,NNE,NNM
      REAL*8       FFE(9),FFM(9)      
      INTEGER      JVITM,JVITP,JACCM
      REAL*8       ACCME(3),VITME(3),ACCMM(3),VITMM(3)
      REAL*8       VITPE(3),VITPM(3)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C CALCUL DES VITESSES/ACCELERATIONS 
C
C ----------------------------------------------------------------------
C
C
C DEPDEL - INCREMENT DE DEPLACEMENT DEPUIS DEBUT DU PAS DE TEMPS
C DEPMOI - DEPLACEMENT DEBUT DU PAS DE TEMPS
C GEOMAx - GEOMETRIE ACTUALISEE GEOM_INIT + DEPMOI 
C
C
C
C IN  NBDM   : NB DE DDL DE LA MAILLE ESCLAVE
C                NDIM = 2 -> NBDM = DX/DY/LAGR_C/LAGR_F1
C                NDIM = 3 -> NBDM = DX/DY/DZ/LAGR_C/LAGR_F1/LAGR_F2
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
C IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
C IN  JVITM  : ADRESSE JEVEUX POUR CHAMP DE VITESSES A L'INSTANT
C              PRECEDENT
C IN  JVITP  : ADRESSE JEVEUX POUR CHAMP DE VITESSES A L'INSTANT
C              COURANT
C IN  JACCM  : ADRESSE JEVEUX POUR CHAMP D'ACCELERATIONS A L'INSTANT
C               PRECEDENT
C OUT VITME  : VITESSE PRECEDENTE DU POINT DE CONTACT
C OUT ACCME  : ACCELERATION PRECEDENTE DU POINT DU CONTACT
C OUT VITMM  : VITESSE PRECEDENTE DU PROJETE DU POINT DE CONTACT
C OUT ACCMM  : ACCELERATION PRECEDENTE  DU PROJETE DU POINT DU CONTACT
C OUT VITPE  : VITESSE COURANTE DU POINT DE CONTACT
C OUT VITPM  : VITESSE COURANTE DU PROJETE DU POINT DU CONTACT
C
C
C
C
      INTEGER   IDIM,INOE,INOM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DO 10 IDIM = 1,3
        VITPM(IDIM)  = 0.D0
        VITPE(IDIM)  = 0.D0
        VITME(IDIM)  = 0.D0 
        ACCME(IDIM)  = 0.D0 
        VITMM(IDIM)  = 0.D0
        ACCMM(IDIM)  = 0.D0
        VITPE(IDIM)  = 0.D0
 10   CONTINUE   
C
C --- POUR LES NOEUDS ESCLAVES
C
      DO 31 IDIM = 1,NDIM
        DO 32 INOE = 1,NNE
          VITPE(IDIM)  = VITPE(IDIM) + FFE(INOE)*
     &                   ZR(JVITP+(INOE-1)*NBDM+IDIM-1)
          VITME(IDIM)  = VITME(IDIM) + FFE(INOE)*
     &                   ZR(JVITM+(INOE-1)*NBDM+IDIM-1)
          ACCME(IDIM)  = ACCME(IDIM) + FFE(INOE)*
     &                   ZR(JACCM+(INOE-1)*NBDM+IDIM-1)
          
32      CONTINUE
31    CONTINUE      
C
C --- POUR LES NOEUDS MAITRES
C
      DO 41 IDIM = 1,NDIM
        DO 42 INOM = 1,NNM
          VITPM(IDIM)  = VITPM(IDIM) + FFM(INOM)*
     &                   ZR(JVITP+NNE*NBDM+(INOM-1)*NDIM+IDIM-1)
          VITMM(IDIM)  = VITMM(IDIM) + FFM(INOM)*
     &                   ZR(JVITM+NNE*NBDM+(INOM-1)*NDIM+IDIM-1)
          ACCMM(IDIM)  = ACCMM(IDIM) + FFM(INOM)*
     &                   ZR(JACCM+NNE*NBDM+(INOM-1)*NDIM+IDIM-1)
         
42      CONTINUE
41    CONTINUE
C
      CALL JEDEMA()
C
      END
