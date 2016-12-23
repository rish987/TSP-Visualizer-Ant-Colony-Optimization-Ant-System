/* 
 * Filename:    Path.pde
 * Author:      Rish Vaishnav
 * Date:        12/22/2016
 *
 * Description:
 * This file contains the Path class. See class header for more information.
 */

/**
 * A Path represents a straight-line path between two points, with a fixed
 * length and changing pheromone value, that can be drawn.
 */
class Path
{
    /* the start and end points of this path; note: swapping the start and end
     * points results in an identical path */
    private Location start_point;
    private Location end_point;
    
    /* the length of this path */
    private double length;

    /* the pheromone on this path */
    private double pheromone;

    /* the initial amount of pheromone on a path */
    private static final double INIT_PHEROMONE = 1;

    /* the evaporation rate of pheromones along a path in one time interval */
    private static final double PHEROMONE_EVAP_RATE = 0.5;

    /* the minimum color of a path */
    public static final int MIN_PATH_COLOR = 0;
    public static final int MAX_PATH_COLOR = 230;

    /* hypothetical maximum pheromone */
    public static final double MAX_PHER = 30;

    /**
     * Create this path with the specified start and end points.
     *
     * @param init_start_point the initial start point
     * @param init_end_point the initial end point
     */
    public Path ( Location init_start_point, Location init_end_point )
    {
        /* set the start and end points of this path */
        this.setPoints( init_start_point, init_end_point );
        
        /* set the length of this path */
        this.resetLength();

        /* set te pheromone on this path */
        this.setPheromone( INIT_PHEROMONE );
    }

    /**
     * Constructs a new path with the default start and end points of (0, 0).
     */
    public Path ()
    {
        this( new Location( 0, 0 ), new Location( 0, 0 ) );
    }

    /**
     * Sets the start and end points to the specified Locations.
     *
     * @param new_start_point the new start point
     * @param new_end_point the new end point
     */
    public void setPoints ( Location new_start_point, Location new_end_point ) 
    {
        /* set the points */
        this.setStartPoint( new_start_point );
        this.setEndPoint( new_end_point );
    }

    /** 
     * Sets the start point of this path. 
     *
     * @param new_start the new start point of this path
     */
    public void setStartPoint ( Location new_start_point )
    {
        this.start_point = new_start_point;
    }

    /** 
     * Sets the end point of this path. 
     *
     * @param new_end the new end point of this path
     */
    public void setEndPoint ( Location new_end_point )
    {
        this.end_point = new_end_point;
    }

    /** 
     * Sets the amount of pheromone on this path. 
     *
     * @param new_pheromone the new amount of pheromone on this path
     */
    public void setPheromone ( double new_pheromone )
    {
        this.pheromone = new_pheromone;
    }

    /** 
     * Resets the length of this path based on the distance between the start
     * and end points.
     */
    public void resetLength ()
    {
        this.length = TSPAlgorithms.get_distance_between( 
            this.start_point, this.end_point );
    }

    /**
     * Adds pheromone to this path as an ant travels across it.
     *
     * @param add the amount of pheromone to add
     */
    public void addPheromone ( double add ) 
    {
        /* add to the current amount of pheromone on this path */
        this.setPheromone( this.getPheromone() + add );
    }

    /**
     * Evaporates pheromone on this path after one time interval.
     */
    public void evaporatePheromone () 
    {
        /* evaporate the current amount of pheromone on this path */
        this.setPheromone( this.getPheromone() * ( 1 - PHEROMONE_EVAP_RATE ) );
    }

    /** 
     * Returns the start point of this path. 
     *
     * @return the start point of this path
     */
    public Location getStartPoint ()
    {
        return this.start_point;
    }

    /** 
     * Returns the end point of this path. 
     *
     * @return the end point of this path
     */
    public Location getEndPoint ()
    {
        return this.end_point;
    }

    /** 
     * Returns the amount of pheromone on this path. 
     *
     * @return the amount of pheromone on this path
     */
    public double getPheromone ()
    {
        return this.pheromone;
    }

    /**
     * Returns the length of this path.
     *
     * @return the length of this path
     */
    public double getLength () 
    {
        return this.length;
    }

    /**
     * Returns the weight of this path, used for calculation of probabilities
     * when ants are choosing between paths.
     *
     * @param pheromone_weight the exponential weight to give the pheromone
     * value when determining the weight
     * @param length_weight the exponential weight to give the length
     * value when determining the weight
     *
     * @return the weight of this path
     */
    public double getWeight ( double pheromone_weight, double length_weight )
    {
        return Math.pow( this.getPheromone(), pheromone_weight ) *
               Math.pow( 1.0/this.getLength(), length_weight );

    }

    /** 
     * Returns whether or not this Path is identical to another path in terms
     * of their start and end points matching.
     *
     * @param path the path to compare to
     */
    public boolean pointsEquals ( Path path )
    {
        /* the paths are equal if they have the same points, disregarding which
         * point is the start or end point */
        return ( this.getStartPoint().equals( path.getStartPoint() )
               && this.getEndPoint().equals( path.getEndPoint() ) ) ||
               ( this.getStartPoint().equals( path.getEndPoint() )
               && this.getEndPoint().equals( path.getStartPoint() ) );
    }
    
    /**
     * Update the graphical representation of this path;
     */
    public void update ()
    {
        /* the color to use */
        int newColor = ( int ) ( MAX_PATH_COLOR - ( this.getPheromone() * 1000 / 
            MAX_PHER ) * ( MAX_PATH_COLOR - MIN_PATH_COLOR ) );

        /* there is enough pheromone to make this path worth showing */
        if ( this.getPheromone() > 1.0e-3 )
        {
            /* set path color */
            stroke( ( int ) ( newColor ) );

            /* draw the path */
            line( ( float ) ( this.getStartPoint().getX() + TSPAlgorithms.ORIGIN_X ),
                  ( float ) ( this.getStartPoint().getY() + TSPAlgorithms.ORIGIN_Y ),
                  ( float ) ( this.getEndPoint().getX() + TSPAlgorithms.ORIGIN_X ),
                  ( float ) ( this.getEndPoint().getY() + TSPAlgorithms.ORIGIN_Y ) );
        }
    }
}
