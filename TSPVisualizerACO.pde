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
private final static int NUM_RAND_LOCS = 40;

/* dimensions of map containin rand_locs */
private final static double RAND_MAP_WIDTH = 500.0;
private final static double RAND_MAP_HEIGHT = 500.0;

/* the map background color */
private final static int BACKGROUND_COLOR = 230;

/* the actual background color */
private final static int BACK_BACKGROUND_COLOR = 200;

/* general offset */
private final static int OFFSET = 10;

/* animation delay */
private final static int DELAY = 10;

/* this map */
private Map this_map;

/* the status panel */
private StatusPanel panel;

/* font size of text */
public static final int TEXT_SIZE = 11;

/**
 * Intitialize program and begin simulation
 */ 
void setup ()
{
    /* set the size of the window */
    size( 540, 700 );

    /* set the title of the window */
    surface.setTitle( "TSP Visualizer - Ant Colony Optimization, Ant System" );

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

    /* initialize the status panel */
    panel = new StatusPanel( OFFSET, OFFSET * 4 + RAND_MAP_WIDTH, this_map );

    /* animate */
    this_map.animateACO();
}

/**
 * Draws the components of the visualizer, updating them as needed.
 */
void draw ()
{
    /* draw the background */
    background( BACK_BACKGROUND_COLOR );

    /* set the color */
    stroke( 0 );
    strokeWeight( 1 );
    fill( BACKGROUND_COLOR );

    /* draw the map box */
    rect( OFFSET, OFFSET, ( float ) RAND_MAP_WIDTH + OFFSET * 2,
         ( float ) RAND_MAP_HEIGHT + OFFSET * 2 );

    /* delay */
    delay( DELAY );

    /* this map has been initialized */
    if ( this_map != null )
    {
        /* update this map */
        this_map.update();
    }

    /* update status panel */
    panel.update();
}

/**
 * Handles the action of typing a key.
 */
void keyTyped () 
{
    /* the 'g' key was typed */
    if ( key == 'g' )
    { 
        /* toggle whether or not we are showing greedy trails */
        this_map.toggleShowGreedy();
    }
    /* the 'a' key was typed */
    if ( key == 'a' )
    { 
        /* toggle whether or not we are showing ACO trails */
        this_map.toggleShowACO();
    }
    /* the 'p' key was typed */
    if ( key == 'p' )
    { 
        /* toggle whether or not we are showing pheromone trails */
        this_map.toggleShowPheromone();
    }
    /* the 'n' key was typed, so randomize and restart this simulation */
    if ( key == 'n' )
    { 
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

        /* reset the locations */
        this_map.setLocs( rand_locs );

        /* toggle whether or not we are showing pheromone trails */
        this_map.animateACO();
    }
    /* the 'r' key was typed, so restart this simulation */
    if ( key == 'r' )
    { 
        /* toggle whether or not we are showing pheromone trails */
        this_map.animateACO();
    }
}
