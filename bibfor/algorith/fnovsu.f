      SUBROUTINE FNOVSU(OPTION,NNO,NNOS,NNOM,NFACE,
     &                  CONGEM,VECTU,
     &                  MECANI,PRESS1,PRESS2,TEMPE,
     &                  DIMCON,DIMUEL,
     &                  TYPVF,AXI,
     &                  NVOIMA,NSCOMA,NBVOIS,
     &                  LIVOIS,TYVOIS,NBNOVO,NBSOCO,LISOCO,
     &                  IPOIDS,IVF,IDFDE,IPOID2,IVF2,IDFDE2,NPI2,JGANO,
     &                  CODRET)
C ======================================================================
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
C ======================================================================
C TOLE CRP_21
C ======================================================================
      IMPLICIT NONE
C
C =====================================================================
C
      INCLUDE 'jeveux.h'
      INTEGER      MAXFA,MAXDIM
      PARAMETER    (MAXFA=6,MAXDIM=3)
      INTEGER      DIMCON,DIMUEL
      INTEGER      CODRET
      INTEGER      MECANI(5),PRESS1(7),PRESS2(7),TEMPE(5)
      INTEGER      TYPVF
      INTEGER      ADCP11,ADCP12,ADCP21,ADCP22
      REAL*8       CONGEM(DIMCON,MAXFA+1)
      REAL*8       VECTU(DIMUEL)
      LOGICAL      AXI
      CHARACTER*16 OPTION
      INTEGER      NNO,NNOS,NNOM,NFACE
C
      INTEGER      NVOIMA,NSCOMA,NBVOIS
      INTEGER      LIVOIS(1:NVOIMA),TYVOIS(1:NVOIMA),NBNOVO(1:NVOIMA),
     &             NBSOCO(1:NVOIMA),LISOCO(1:NVOIMA,1:NSCOMA,1:2)
C
      REAL*8       MFACE(1:MAXFA),DFACE(1:MAXFA),
     >             XFACE(1:MAXDIM,1:MAXFA),
     >             NORMFA(1:MAXDIM,1:MAXFA),SFACE(1:MAXFA)
C
      INTEGER      IFA,FA
      INTEGER      IPOIDS,IVF,IDFDE,IPOID2,IVF2,IDFDE2,NPI2,JGANO
C
C =====================================================================
C.......................................................................
C
C BUT: CALCUL DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
C EN MECANIQUE DES MILIEUX POREUX AVEC COUPLAGE THM
C.......................................................................
C =====================================================================
C IN AXI AXISYMETRIQUE?
C IN NNO NB DE NOEUDS DE L'ELEMENT
C IN NNOS NB DE NOEUDS SOMMETS DE L'ELEMENT
C IN NFACE NB DE FACES AU SENS BORD DE DIMENSION DIM-1 NE SERT QU EN VF
C IN NNOM NB DE NOEUDS MILIEUX DE FACE OU D ARRETE NE SERT QU EN EF
C IN NDDLS NB DE DDL SUR LES SOMMETS
C IN NDDLM NB DE DDL SUR LES MILIEUX
C IN NDDLK NB DE DDL AU CENTRE
C IN TYPVF 1 : SCHEMA A DEUX POINTS
C IN NDIM DIMENSION DE L'ESPACE
C IN DIMUEL NB DE DDL TOTAL DE L'ELEMENT
C =====================================================================
C IN GEOM : COORDONNEES DES NOEUDS
C IN OPTION : OPTION DE CALCUL
C IN MECANI : TABLEAU CONTENANT
C NDEFME = MECA(4), NOMBRE DE DEFORMATIONS MECANIQUES
C NCONME = MECA(5), NOMBRE DE CONTRAINTES MECANIQUES
C IN PRESS1 : TABLEAU CONTENANT
C ADCP11=PRESS1(4), ADRESSE DANS LES TABLEAUX DES CONTRAIN
C GENERALISEES AU POINT DE GAUSS CONGEM ET CONGEM DES
C CONTRAINTES CORRESPONDANT A LA PREMIERE PHASE DU
C PREMIER CONSTITUANT
C ADCP12=PRESS1(5), ADRESSE DANS LES TABLEAUX DES CONTRAIN
C GENERALISEES AU POINT DE GAUSS CONGEM ET CONGEM DES
C CONTRAINTES CORRESPONDANT A LA DEUXIEME PHASE DU
C PREMIER CONSTITUANT
C NDEFP1 = PRESS1(6), NOMBRE DE DEFORMATIONS PRESSION 1
C NCONP1 = PRESS1(7), NOMBRE DE CONTRAINTES POUR
C CHAQUE PHASE DU CONSTITUANT 1
C IN PRESS2 : TABLEAU CONTENANT
C ADCP21=PRESS2(4), ADRESSE DANS LES TABLEAUX DES CONTRAIN
C GENERALISEES AU POINT DE GAUSS CONGEM ET CONGEM DES
C CONTRAINTES CORRESPONDANT A LA PREMIERE PHASE DU
C SECOND CONSTITUANT
C ADCP22=PRESS2(5), ADRESSE DANS LES TABLEAUX DES CONTRAIN
C GENERALISEES AU POINT DE GAUSS CONGEM ET CONGEM DES
C CONTRAINTES CORRESPONDANT A LA DEUXIEME PHASE DU
C SECOND CONSTITUANT
C NDEFP2 = PRESS2(6), NOMBRE DE DEFORMATIONS PRESSION 2
C NCONP2 = PRESS2(7), NOMBRE DE CONTRAINTES POUR
C CHAQUE PHASE DU CONSTITUANT 2
C
C IN TEMPE : TABLEAU CONTENANT
C NDEFTE = TEMPE(4), NOMBRE DE DEFORMATIONS THERMIQUES
C NCONTE = TEMPE(5), NOMBRE DE CONTRAINTES THERMIQUES
C OUT CODRET : CODE RETOUR LOIS DE COMPORTEMENT
C OUT VECTU : FORCES NODALES (RAPH_MECA ET FULL_MECA)
C......................................................................
C
C VAIABLES LOCALES POUR CALCULS VF
C
C
C PCM PRESSION CAPILLAIRE
C PGM PRESSION DE GAZ
C PCMV PRESSION CAPILLAIRE CENTRE VOISIN
C PGMV PRESSION GAZ CENTRE VOISIN
C PWM PRESSION EAU
C PWMV PRESSION EAU VOISIN
C CVP CONCENTRATION VAPEUR DANS PHASE GAZEUSE
C CVPV CONCENTRATION VAPEUR DANS PHASE GAZEUSE VOISIN
C CAS CONCENTRATION AIR SEC DANS PHASE GAZEUSE
C CASV CONCENTRATION AIR SEC DANS PHASE GAZEUSE VOISIN
C CAD CONCENTRATION AIR DISSOUS
C CADV CONCENTRATION AIR DISSOUS VOISIN
C KINTFA PERMEABILITE INTRINSEQUE SUR UNE FACE
C NT*K*N CACULEE PAR MOYENNE HARMONIQUE
C MOBWFA MOBILITE EAU SUR FACE
C MOADFA MOBILITE AIR DISSOUS SUR FACE
C MOASFA MOBILITE AIR SEC SUR FACE
C MOVPFA MOBILITE VAPEUR SUR FACE
C SFLUW SOMME SUR FACES FLUX EAU
C SFLUVP SOMME SUR FACES FLUX VAPEUR
C SFLUAS SOMME SUR FACES FLUX AIR SEC
C SFLUAD SOMME SUR FACES FLUX AIR DISSOUS
C
      REAL*8       SFLUW,SFLUVP,SFLUAS,SFLUAD
      INTEGER      ADCM1,ADCM2,ADCF1,ADCF2
C
C FONCTIONS FORMULES D ADRESSAGE DES DDL
C
C

      ADCF1(FA)=2*(FA-1)+1
      ADCF2(FA)=2*(FA-1)+2
      IF ( TYPVF.EQ.1) THEN
       ADCM1 = 1
       ADCM2 = 2
      ELSE
       ADCM1 = 2*NFACE+1
       ADCM2 = 2*NFACE+2
      ENDIF
C
      CALL ASSERT(OPTION.EQ.'FORC_NODA')
C =====================================================================
C --- DETERMINATION DES VARIABLES CARACTERISANT LE MILIEU -------------
C =====================================================================
      ADCP11 = PRESS1(4)
      ADCP12 = PRESS1(5)
      ADCP21 = PRESS2(4)
      ADCP22 = PRESS2(5)
C =====================================================================
C --- CALCUL DES QUANTITES GEOMETRIQUES
C =====================================================================
C
C TERMES DE FLUX
C
      IF(TYPVF.EQ.1) THEN
         SFLUW = CONGEM(ADCP11+1,1)
         SFLUVP = CONGEM(ADCP12+1,1)
         SFLUAS =CONGEM(ADCP21+1,1)
         SFLUAD = CONGEM(ADCP22+1,1)
         VECTU(ADCM1) = SFLUW+SFLUVP
         VECTU(ADCM2) = SFLUAS+SFLUAD
      ELSE IF ((TYPVF.EQ.2)) THEN
         DO 2 IFA=1,NFACE
            VECTU(ADCF1(IFA))=CONGEM(ADCP11+1,IFA+1)
            VECTU(ADCF2(IFA))=CONGEM(ADCP12+1,IFA+1)
    2    CONTINUE
         SFLUW =CONGEM(ADCP11+1,1)
         SFLUVP =CONGEM(ADCP12+1,1)
         SFLUAS =CONGEM(ADCP21+1,1)
         SFLUAD =CONGEM(ADCP22+1,1)
         VECTU(ADCM1)= SFLUW+SFLUVP
         VECTU(ADCM2)= SFLUAS+SFLUAD
      ELSE
         CALL U2MESG('F','VOLUFINI_9',0,' ',1,TYPVF,0,0.D0)
      ENDIF
C ======================================================================
C ======================================================================
      END
