/* 
 * Filename:    TSPVisualizerACO.pde
 * Author:      Rish Vaishnav
 * Date:        12/22/2016
 *
 * Description:
 * This file contains the necessary methods to display the TSP Visualizer for
 * the Ant Colony Optimization algorithm. See method headers for more
 * information.
 */

/* the number of random locations to create */
private final static int NUM_RAND_LOCS = 10;

/* dimensions of map containin rand_locs */
private final static double RAND_MAP_WIDTH = 500.0;
private final static double RAND_MAP_HEIGHT = 500.0;

/* the background color */
private final static int BACKGROUND_COLOR = 230;

/* this map */
Map this_map;

/**
 * Intitialize program and begin simulation
 */ 
void setup ()
{
    /* set the size of the window */
    size( 540, 540 );

    /* set the title of the window */
    surface.setTitle( "TSP Visualizer - Ant Colony Optimization" );

    /* draw the background */
    background( BACKGROUND_COLOR );
    
    /* random locations */
    Location[] rand_locs = new Location[ NUM_RAND_LOCS ];
    
    /* go through all of the locations in rand_locs */
    for ( int rand_locs_i = 0; rand_locs_i < NUM_RAND_LOCS; rand_locs_i++ )
    {
        /* set this random location to a new randomized location */
        rand_locs[ rand_locs_i ] = new Location( 
            Math.random() * RAND_MAP_WIDTH,
            Math.random() * RAND_MAP_HEIGHT );
    }

    /* initialize the map */
    this_map = new Map( rand_locs );

    this_map.animateACO();

    /* get the basic ACO tour through the random locs */
    //Location[] ACO_basic_tour = sol_ACO_AS( this_map );
}

/**
 * Draws the components of the visualizer, updating them as needed.
 */
void draw ()
{
    /* draw the background */
    background( BACKGROUND_COLOR );

    /* delay */
    delay( 10 );

    /* this map has been initialized */
    if ( this_map != null )
    {
        /* update this map */
        this_map.update();
    }
}
