class ExerciseProgress
  attr_reader :daily

  def initialize(user:, exercise:, since: nil)
    records = user.workouts.joins(:workout_records)
      .where(workout_records: { exercise_id: exercise.id })
      .includes(workout_records: :workout_sets).distinct.order(:date, :id)
    records = records.where("date >= ?", since) if since
    @daily = records.group_by(&:date).map do |date, workouts|
      sets = workouts.flat_map { |workout| workout.workout_records.select { |r| r.exercise_id == exercise.id }.flat_map(&:workout_sets) }
      { date: date, weight: sets.filter_map(&:weight_kg).max&.to_f,
        volume: sets.sum { |set| (set.weight_kg || 0) * set.reps }.to_f,
        reps: sets.sum(&:reps), sets: sets.size }
    end
  end

  def labels
    daily.map { |day| day[:date].strftime("%Y/%m/%d") }
  end

  def values(metric)
    daily.map { |day| day.fetch(metric.to_sym) }
  end

  def personal_best
    values(:weight).compact.max
  end
end
