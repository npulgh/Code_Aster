      SUBROUTINE NMINI0(NOMPRO,COMGEO,CSEUIL,COBCA,NMODAM,NBMODS,COEDEP,
     &                 COEVIT,COEACC,ETA,LONDE,LIMPED,LAMORT,LBID,K8BID,
     &                 K13BID,K24BID,LICCVG,NUMINS,PREMIE,DECOL ,MTCPUI,
     &                 MTCPUP,LISCH2,BASENO,INPSCO,FINPAS,ZFON  ,FONACT)
     
     
        
      IMPLICIT NONE
      INTEGER      ZFON
      LOGICAL      LONDE , LIMPED, LAMORT, LBID,   PREMIE, DECOL
      LOGICAL      MTCPUI, MTCPUP, FINPAS
      INTEGER      COMGEO, CSEUIL, COBCA,  NMODAM, NBMODS, LICCVG(5)
      INTEGER      NUMINS
      REAL*8       COEDEP,COEVIT,COEACC,ETA
      CHARACTER*6  NOMPRO
      CHARACTER*8  K8BID,BASENO
      CHARACTER*13 K13BID,INPSCO
      CHARACTER*19 LISCH2
      CHARACTER*24 K24BID
      LOGICAL      FONACT(ZFON)
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/02/2006   AUTEUR GREFFET N.GREFFET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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

C RESPONSABLE MABBAS M.ABBAS
C TOLE CRP_21

C ----------------------------------------------------------------------
C -- LES PREMIERES INITIALISATIONS DE STAT_NON_LINE
C --    MISE A ZERO
C ----------------------------------------------------------------------
C      IN  NOMPRO : NOM DE LA ROUTINE APPELANTE (OP0070 A PRIORI)
C      OUT COMGEO : ?
C      OUT CSEUIL : ?
C      OUT COBCA  : ?
C      OUT NMODAM : AMORTISSEMENT MODAL (?)
C      OUT NBMODS : NOMBRE MODE STATIQUE (MODELISATION MULTI-APPUI) (?)
C      OUT COEVIT : ?
C      OUT COEACC : ?
C      OUT ETA    : PARAMETRE PILOTAGE
C      OUT LONDE  : BOOLEEN D'EXISTENCE DE CHARGES 'ONDE_PLANE'
C      OUT LIMPED : BOOLEEN DE PRESENCE D'ELEMENTS 'IMPE_ABSO'
C      OUT LAMORT : BOOLEEN D'EXISTENCE D'AMORTISSEMENT
C      OUT LICCVG : CODE RETOUR CONVERGENCE CONTACT
C      OUT NUMINS : COMPTEUR DE LA BOUCLE EN TEMPS
C      OUT PREMIE : BOOLEEN POUR LE PREMIER PAS
C      OUT DECOL  : ?
C      OUT MTCPUI : BOOLEEN DE MANQUE TEMPS CPU (ITERATION)
C      OUT MTCPUP : BOOLEEN DE MANQUE TEMPS CPU (PAS DE TEMPS)
C      OUT LISCH2 : NOM DE LA SD INFO CHARGE POUR STOCKAGE DANS LA SD
C                   RESULTAT
C      OUT BASENO : NOM DE BASE DES CONCEPTS
C      OUT INPSCO : SD CONTENANT LA LISTE DES NOMS POUR LA SENSIBILITE
C      OUT FINPAS : BOOLEEN POUR INDIQUER QU'ON EST A LA FIN DES PAS
C      OUT FONACT : FONCTIONNALITES ACTIVEES
C ----------------------------------------------------------------------
      
      CHARACTER*24 NOOBJ
      
C -- INITIALISATIONS UTILES

      BASENO = '&&'//NOMPRO
      INPSCO = '&&'//NOMPRO//'_PSCO'


      COMGEO = 0
      CSEUIL = 0
      COBCA  = 0
      NMODAM = 0
      NBMODS = 0
      COEDEP = 1.D0
      COEVIT = 0.D0
      COEACC = 0.D0
      ETA    = 0.D0
      LONDE  = .FALSE.
      LIMPED = .FALSE.
      LAMORT = .FALSE.
      LBID   = .FALSE.
      FINPAS = .FALSE.
      K8BID  = ' '   
      K13BID = ' '   
      K24BID = ' '   

C -- INITIALISATION DES INDICATEURS DE CONVERGENCE 
C              LICCVG(1) : PILOTAGE
C                        =  0 CONVERGENCE
C                        =  1 PAS DE CONVERGENCE
C                        = -1 BORNE ATTEINTE
C              LICCVG(2) : INTEGRATION DE LA LOI DE COMPORTEMENT
C                        = 0 OK
C                        = 1 ECHEC DANS L'INTEGRATION : PAS DE RESULTATS
C                        = 3 SIZZ NON NUL (DEBORST) ON CONTINUE A ITERER
C              LICCVG(3) : TRAITEMENT DU CONTACT 
C                        = 0 OK
C                        = 1 ECHEC (ITER > 2*NBLIAI+1)
C              LICCVG(4) : MATRICE DE CONTACT
C                        = 0 OK
C                        = 1 MATRICE DE CONTACT SINGULIERE
C              LICCVG(5) : MATRICE DU SYSTEME (MATASS)
C                        = 0 OK
C                        = 1 MATRICE SINGULIERE
      LICCVG(1) = 0
      LICCVG(2) = 0
      LICCVG(3) = 0
      LICCVG(4) = 0
      LICCVG(5) = 0

C -- INITIALISATION BOUCLE EN TEMPS
      NUMINS = 1
      PREMIE = .TRUE.
      DECOL  = .FALSE.
      MTCPUI = .FALSE.
      MTCPUP = .FALSE.

C     DETERMINATION DU NOM DE LA SD INFO_CHARGE STOCKEE
C     DANS LA SD RESULTAT
C             12345678    90123    45678901234   
      NOOBJ ='12345678'//'.1234'//'.EXCIT01234'      
      CALL GNOMSD(NOOBJ,10,13)
      LISCH2 = NOOBJ(1:19)

C -- FONCTIONNALITES ACTIVEES
      FONACT(1)  = .FALSE.
      FONACT(2)  = .FALSE.
      FONACT(3)  = .FALSE.
      FONACT(4)  = .FALSE.
      FONACT(5)  = .FALSE.
      FONACT(6)  = .FALSE.
      FONACT(7)  = .FALSE.
      FONACT(8)  = .FALSE.
      FONACT(9)  = .FALSE.
      FONACT(10) = .FALSE.


      END
